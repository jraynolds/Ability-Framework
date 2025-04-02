extends Effect
## The runtime instance of an EffectResource that temporarily modifies an Entity.
## Like an Effect but with lifetime, duration, etc.
class_name StatusEffect

#var tracking_lifetime : bool ## Whether the StatusEffect is currently tracking its lifetime.
var _lifetimes : Array[LifetimeResource] = [] ## The lifetimes before this StatusEffect expires.
## The duration the associated StatusEffect has been active. Compared with the LifetimeResource.
var _duration : float = 0 :
	set(val):
		_duration = val
		if has_lifetime_duration() and get_lifetime_duration_left() <= 0:
			on_lifetime_ended.emit()
 ## The times the associated StatusEffect has been triggered. Compared with the LifetimeResource.
var _times_triggered : int = 0
## What should happen when the Effect reaches the end of a Lifetime. By default, we reduce its stacks by 1.
var _expiration_behavior : StatusAddEffectResource.ExpirationBehavior


## Updates this StatusEffect's Resource with another. Overloaded.
func update_resource(res: EffectResource):
	super(res)
	_duration = 0
	_times_triggered = 0


## Returns an instance of this initialized with the given EffectResource.
func from_resource(res: EffectResource, ability: Ability, caster: Entity, targets: Array[Entity]) -> Effect:
	update_resource(res)
	_caster = caster
	_ability = ability
	_targets = targets
	name = _title
	_resource.on_created(self, ability, caster, targets)
	
	return self


## Returns an instance of this initialized with the given Effect.
func from_effect(effect: Effect) -> Effect:
	_resource = effect.resource
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


## Returns an instance of this initialized with the given Lifetime and ExpirationBehavior.
func with_status(lifetimes: Array[LifetimeResource], expiry: StatusAddEffectResource.ExpirationBehavior):
	_lifetimes = []
	for lifetime in lifetimes:
		_lifetimes.append(lifetime)
	_expiration_behavior = expiry
	
	return self


## Returns an instance of this initialized with the given StatusEffect.
func from_status_effect(status: StatusEffect) -> StatusEffect:
	from_effect(status)
	for lifetime in status._lifetimes:
		_lifetimes.append(lifetime)
	_duration = status._duration
	_times_triggered = status._times_triggered
	_lifetimes = []
	
	return self


## Performs this StatusEffect on the given targets, from the given caster. Overloaded.
func affect(caster: Entity, targets: Array[Entity]):
	super(caster, targets)
	
	_times_triggered += 1
	
	if _lifetimes.is_empty():
		queue_free()
	else :
		var ended = false
		if _lifetimes.any(
			func(lifetime: LifetimeResource): lifetime.is_lifetime_expired(caster, targets, 0, _times_triggered)
		):
			queue_free()


## Returns whether this StatusEffect has an active DurationLifetime on it.
func has_lifetime_duration() -> bool:
	for lifetime in _lifetimes:
		var lifetime_duration = lifetime as DurationLifetimeResource
		if lifetime_duration:
			return true
	return false


## Returns the lowest lifetime duration on this StatusEffect, or -1 if there is none.
func get_lifetime_duration_left() -> float:
	assert(has_lifetime_duration(), "There's no lifetime duration active!")
	var lowest_lifetime = 9999
	for lifetime in _lifetimes:
		var lifetime_duration = lifetime as DurationLifetimeResource
		if lifetime_duration:
			lowest_lifetime = min(lowest_lifetime, lifetime_duration.duration.get_value(_caster, _targets))
	return lowest_lifetime - _duration


## Resets duration and triggers.
func reset_lifetime():
	_duration = 0
	_times_triggered = 0
