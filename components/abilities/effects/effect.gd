extends Node
## The runtime instance of an EffectResource.
class_name Effect

var _resource : EffectResource ## The base EffectResource this Effect represents.
## Get/Setter for the EffectResource. Changing it creates instance copies of many of its fields.
var resource : EffectResource :
	get :
		return _resource
	set(val):
		_resource = val
		_title = _resource.title
		_description = _resource.description
		_positivity = _resource.positivity
		_icon = _resource.icon
		for trigger in _resource.triggers:
			_triggers.append(trigger)
		for lifetime in _resource.lifetimes:
			_lifetimes.append(lifetime)
		for conditional in _resource.conditionals_positive:
			_conditionals_positive.append(conditional)
		for conditional in _resource.conditionals_negative:
			_conditionals_negative.append(conditional)
		_duration = 0
		_times_triggered = 0
var _title : String ## The title of this Effect.
var _description : String ## The description of this Effect.
var _positivity : Math.Positivity ## Whether this Effect is good, bad, or neither for its target.
var _icon : Texture2D ## The icon for this Effect.
var _triggers : Array[TriggerResource] = [] ## The triggers that cause this Effect.
var _lifetimes : Array[LifetimeResource] = [] ## The lifetimes before this Effect expires.
var _conditionals_positive : Array[ConditionalResource] = [] ## The conditionals that allow this Effect.
var _conditionals_negative : Array[ConditionalResource] = [] ## The conditionals that disallow this Effect.

var _caster : Entity ## The Entity responsible for the creation of this Effect.
var _ability : Ability ## The Ability that created this Effect.
var _targets : Array[Entity] ## The Entities targeted by this Effect.
#var tracking_lifetime : bool ## Whether the Effect is currently tracking its lifetime.
## The duration the associated Effect has been active. Compared with the LifetimeResource.
var _duration : float = 0 :
	set(val):
		_duration = val
		if has_lifetime_duration() and get_lifetime_duration_left() <= 0:
			on_lifetime_ended.emit()
 ## The times the associated Effect has been triggered. Compared with the LifetimeResource.
var _times_triggered : int = 0

signal on_registered ## Emitted when this Effect is fully registered on all its Triggers.
signal on_affected(caster: Entity, targets: Array[Entity]) ## Emitted when this Effect affects its targets.
signal on_unregistered ## Emitted when this Effect is fully unregistered on all its Triggers.
signal on_lifetime_ended ## Emitted when any of this Effect's lifetimes expires.
signal on_ended ## Emitted when this Effect expires.

## Returns an instance of this initialized with the given EffectResource.
func from_resource(res: EffectResource, caster: Entity, ability: Ability, targets: Array[Entity]) -> Effect:
	resource = res
	_caster = caster
	_ability = ability
	_targets = targets
	name = _title
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
	for lifetime in effect._lifetimes:
		_lifetimes.append(lifetime)
	for conditional in effect._conditionals_positive:
		_conditionals_positive.append(conditional)
	for conditional in effect._conditionals_negative:
		_conditionals_negative.append(conditional)
	_duration = 0
	_times_triggered = 0
	_caster = effect._caster
	_ability = effect._ability
	_targets = effect._targets
	name = _title
	return self


## If usable, makes a copy and registers this effect on the appropriate triggers.
func register(caster: Entity, targets: Array[Entity]):
	print("Registering " + _title)
	
	for conditional in _conditionals_positive:
		if !conditional.is_met(self, _ability, caster, targets):
			return
	for conditional in _conditionals_negative:
		if conditional.is_met(self, _ability, caster, targets):
			return
	
	assert(targets[0], "No valid targets to register on")
	var effect_temp : Effect = self.duplicate(10).from_effect(self) ## Duplicates with values
	effect_temp.name = "targeting "
	for target in targets:
		effect_temp.name += target.title + " "
	add_child(effect_temp, true)
	
	for trigger in _triggers:
		trigger.register(effect_temp, _ability, caster, targets, effect_temp.affect)
	
	print("Finished registering " + _title)
	on_registered.emit()


## Performs this Effect on the given targets, from the given caster.
func affect(caster: Entity, targets: Array[Entity]):
	print("affecting with " + _title)
	print(targets[0].title)
	
	_times_triggered += 1
	
	for target in targets:
		_resource.affect(caster, _ability, self, targets)
	
	if _lifetimes.is_empty():
		queue_free()
	else :
		var ended = false
		if _lifetimes.any(
			func(lifetime: LifetimeResource): lifetime.is_lifetime_expired(caster, targets, 0, _times_triggered)
		):
			queue_free()


## Returns whether this Effect has an active DurationLifetime on it.
func has_lifetime_duration() -> bool:
	for lifetime in _lifetimes:
		var lifetime_duration = lifetime as DurationLifetimeResource
		if lifetime_duration:
			return true
	return false


## Returns the lowest lifetime duration on this Effect, or -1 if there is none.
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


## Returns whether the given Effect shares our same EffectResource.
func shares_resource(effect: Effect) -> bool:
	return effect.resource == resource


## Ends this Effect.
func end():
	on_ended.emit()
	queue_free()
