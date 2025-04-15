extends Effect
## The runtime instance of an EffectResource that temporarily modifies an Entity.
## Like an Effect but with lifetime, duration, etc.
class_name StatusEffect

#var tracking_lifetime : bool ## Whether the StatusEffect is currently tracking its lifetime.
var _lifetime : ValueResource ## The lifetimes before this StatusEffect expires.
var lifetime_remaining : float :
	get :
		if !_lifetime:
			return NAN
		return _lifetime.get_value(_caster, _targets) - _time_active
var _expirations : Array[ExpirationResource] = [] ## A list of triggers that cause this StatusEffect to end early.

## The duration the associated StatusEffect has been active. Compared with the lifetime.
var _time_active : float = 0 :
	set(val):
		var old_value = _time_active
		_time_active = val
		on_time_active_changed.emit(_time_active, old_value)
		if lifetime_remaining < 0:
			end()
## The times the associated StatusEffect has been triggered.
var _times_triggered : int = 0 :
	set(val):
		var old_value = _times_triggered
		_times_triggered = val
		on_times_triggered_changed.emit(_times_triggered, old_value)
var is_visible : bool ## Whether the StatusEffect should be visible on the GUI.

signal on_time_active_changed(new_value: float, old_value: float) ## Emitted when the time active changes.
signal on_times_triggered_changed(new_vlaue: float, old_value: float) ## Emitted when the number of times triggered changes.

## Updates this StatusEffect's Resource with another. Overloaded.
func update_resource(res: EffectResource):
	super(res)
	_time_active = 0
	_times_triggered = 0


## Returns an instance of this initialized with the given EffectResource.
func from_resource(res: EffectResource, ability: Ability, caster: Entity, targets: Array[Entity]) -> Effect:
	assert(res, "The resource is null!")
	update_resource(res)
	_caster = caster
	_ability = ability
	_targets = targets
	name = _title
	_resource.on_created(self, ability, caster, targets)
	
	return self


## Returns an instance of this initialized with the given Effect.
func from_effect(effect: Effect) -> Effect:
	_resource = effect._resource
	_title = effect._title
	_description = effect._description
	_positivity = effect._positivity
	_icon = effect._icon
	for trigger in effect._triggers:
		_triggers.append(trigger)
	for conditional in effect._conditionals_positive:
		_conditionals_positive.append(conditional)
	for conditional in effect._conditionals_negative:
		_conditionals_negative.append(conditional)
	_caster = effect._caster
	_ability = effect._ability
	_targets = effect._targets
	name = _title
	_resource.on_created(self, _ability, _caster, _targets)
	
	return self


## Returns an instance of this initialized with the given lifetime and expirations.
func with_expiration(lifetime: ValueResource, expirations: Array[ExpirationResource]) -> StatusEffect:
	_lifetime = lifetime
	for expiration in expirations:
		_expirations.append(expiration)
	
	return self


## Returns an instance of this initialized with the given StatusEffect.
func from_status_effect(status: StatusEffect) -> StatusEffect:
	from_effect(status)
	_lifetime = status._lifetime
	for expiration in status._expirations:
		_expirations.append(expiration)
	_time_active = status._time_active
	_times_triggered = status._times_triggered
	
	return self


## If usable, registers this effect on the appropriate triggers.
func register(caster: Entity, targets: Array[Entity]):
	_caster = caster
	_targets = targets
	
	DebugManager.debug_log(
		"Attempting to register StatusEffect " + _title
	, self)
	
	for conditional in _conditionals_positive:
		if !conditional.is_met(self, _ability, caster, targets):
			DebugManager.debug_log(
				"Couldn't register StatusEffect " + _title + 
				" because it didn't meet conditional " + conditional.resource_name
			, self)
			return
	for conditional in _conditionals_negative:
		if conditional.is_met(self, _ability, caster, targets):
			DebugManager.debug_log(
				"Couldn't register StatusEffect " + _title + 
				" because it met conditional " + conditional.resource_name
			, self)
			return
	
	DebugManager.debug_log(
		"Registering StatusEffect " + _title
	, self)
	
	for trigger in _triggers:
		trigger.register(self, _ability, caster, targets, affect)
	for expiration in _expirations:
		expiration.register(self, _ability, caster, targets)
	on_registered.emit()
	
	DebugManager.debug_log(
		"Registered StatusEffect " + _title
	, self)


## Performs this StatusEffect on the given targets, from the given caster. Overloaded.
func affect(caster: Entity, targets: Array[Entity]):
	DebugManager.debug_log(
		"Affecting targets with StatusEffect " + _title
	, self)
	
	for target in targets:
		DebugManager.debug_log(
			"Affecting target " + target._resource.title + " with StatusEffect " + _title
		, self)
		_resource.on_affect(self, _ability, caster, targets)
	
	_times_triggered += 1


## Causes this StatusEffect to expire according to the behavior of the given ExpirationResource.
## caster and targets are extraneous parameters necessary to square with how our triggers work.
func expire_from_resource(expiration: ExpirationResource, caster: Entity, targets: Array[Entity]):
	DebugManager.debug_log(
		"StatusEffect " + _title + " is expiring from effect " + expiration.resource_name
	, self)
	expiration.expire_effect(self, _ability, _caster, _targets)


## Resets time active and triggers.
func reset_lifetime():
	_time_active = 0
	_times_triggered = 0
