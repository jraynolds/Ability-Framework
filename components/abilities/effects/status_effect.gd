extends Effect
## The runtime instance of an EffectResource that temporarily modifies an Entity.
## Like an Effect but with lifetime, duration, etc.
class_name StatusEffect

var is_visible : bool ## Whether the StatusEffect should be visible on the GUI.
#var tracking_lifetime : bool ## Whether the StatusEffect is currently tracking its lifetime.
var _lifetime : ValueResource ## The lifetimes before this StatusEffect expires.
var lifetime_remaining : float :
	get :
		if !_lifetime:
			return NAN
		return _lifetime.get_value(
			EffectInfo.new(), 
			{"effect": self, "ability": _ability, "caster": _caster, "targets": _targets}
		) - _time_active
var _expirations : Array[ExpirationResource] = [] ## A list of triggers that cause this StatusEffect to end early.

## The duration the associated StatusEffect has been active. Compared with the lifetime.
var _time_active : float = 0 :
	set(val):
		#var old_value = _time_active
		_time_active = val
		#on_time_active_changed.emit(_time_active, old_value)
		if lifetime_remaining < 0:
			end()

## Updates this StatusEffect's Resource with another. Overloaded.
func update_resource(res: EffectResource):
	super(res)
	_time_active = 0

#signal on_time_active_changed(new_value: float, old_value: float) ## Emitted when the time active changes.

## Returns an instance of this initialized with the given EffectResource.
func from_resource(res: EffectResource, ability: Ability, caster: Entity) -> Effect:
	assert(res, "The resource is null!")
	update_resource(res)
	_ability = ability
	_caster = caster
	name = _title
	_resource.on_created(EffectInfo.new(), _self_as_override)
	
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
	_resource.on_created(EffectInfo.new(self, _ability, _caster, _targets))
	
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
	
	return self


## If usable, registers this effect on the appropriate triggers.
func register(_a: Ability, caster: Entity, targets: Array[Entity]):
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	#var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
		
	_caster = caster
	_targets = targets
	
	DebugManager.debug_log(
		"Attempting to register StatusEffect " + _title
	, self)
	
	for conditional in _conditionals_positive:
		if !conditional.is_met(EffectInfo.new(), _self_as_override):
			DebugManager.debug_log(
				"Couldn't register StatusEffect " + _title + 
				" because it didn't meet conditional " + conditional.resource_name
			, self)
			return
	for conditional in _conditionals_negative:
		if conditional.is_met(EffectInfo.new(), _self_as_override):
			DebugManager.debug_log(
				"Couldn't register StatusEffect " + _title + 
				" because it met conditional " + conditional.resource_name
			, self)
			return
	
	DebugManager.debug_log(
		"Registering StatusEffect " + _title
	, self)
	
	for trigger in _triggers:
		trigger.register(_self_as_effect_info, {}, affect)
	for expiration in _expirations:
		expiration.register(_self_as_effect_info, {})
	on_registered.emit()
	
	DebugManager.debug_log(
		"Registered StatusEffect " + _title
	, self)


## Performs this Effect on the given targets, from the given caster, from the given trigger. Overloaded.
func affect(trigger: TriggerResource=null):
	DebugManager.debug_log(
		"Affecting targets with StatusEffect " + _title + " from the trigger " + trigger.resource_path
	, self) 
	
	if trigger in times_triggered:
		times_triggered[trigger] += 1
	else :
		times_triggered[trigger] = 1
	
	for target in _targets:
		DebugManager.debug_log(
			"Affecting target " + target._resource.title + " with StatusEffect " + _title +
			" from the trigger " + trigger.resource_path
		, self)
		_resource.on_affect(_self_as_effect_info)


## Causes this StatusEffect to expire according to the behavior of the given ExpirationResource.
func expire_from_resource(trigger: TriggerResource, expiration: ExpirationResource):
	DebugManager.debug_log(
		"StatusEffect " + _title + " is expiring from effect " + expiration.resource_name + " given trigger " +
		trigger.resource_name
	, self)
	expiration.expire_effect(_self_as_effect_info)
 

## Resets time active and triggers.
func reset_lifetime():
	_time_active = 0
	times_triggered = {}
