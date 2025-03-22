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
var _icon : Texture2D ## The icon for this Effect.
var _triggers : Array[TriggerResource] = [] ## The triggers that cause this Effect.
var _lifetimes : Array[LifetimeResource] = [] ## The lifetimes before this Effect expires.
var _conditionals_positive : Array[ConditionalResource] = [] ## The conditionals that allow this Effect.
var _conditionals_negative : Array[ConditionalResource] = [] ## The conditionals that disallow this Effect.

## The duration the associated Effect has been active. Compared with the LifetimeResource.
var _duration : float = 0 
 ## The times the associated Effect has been triggered. Compared with the LifetimeResource.
var _times_triggered : int = 0

signal on_registered ## Emitted when this Effect is fully registered on all its Triggers.
signal on_affected(caster: Entity, targets: Array[Entity]) ## Emitted when this Effect affects its targets.
signal on_unregistered ## Emitted when this Effect is fully unregistered on all its Triggers.
signal on_ended ## Emitted when this Effect expires.

## Returns an instance of this initialized with the given EffectResource.
func from_resource(res: EffectResource) -> Effect:
	resource = res
	return self


## Returns an instance of this initialized with the given Effect.
func from_effect(effect: Effect) -> Effect:
	_resource = effect.resource
	_title = effect._title
	_description = effect._description
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
	return self


## If usable, makes a copy and registers this effect on the appropriate triggers.
func register(ability: Ability, caster: Entity, targets: Array[Entity]):
	for conditional in _conditionals_positive:
		if !conditional.is_met(self, ability, caster, targets):
			return
	for conditional in _conditionals_negative:
		if conditional.is_met(self, ability, caster, targets):
			return
	
	assert(targets[0], "No valid targets to register on")
	var effect_temp : Effect = self.duplicate(10).from_effect(self) ## Duplicates with values
	effect_temp.name = "targeting "
	for target in targets:
		effect_temp.name += target.title + " "
	add_child(effect_temp, true)
	
	for trigger in _triggers:
		trigger.register(effect_temp, ability, caster, targets, effect_temp.affect)


## Performs this Effect on the given targets, from the given caster.
func affect(caster: Entity, targets: Array[Entity]):
	_times_triggered += 1
	
	for target in targets:
		_resource.affect(caster, targets)
	
	if _lifetimes.is_empty():
		queue_free()
	else :
		var ended = false
		if _lifetimes.any(
			func(lifetime: LifetimeResource): lifetime.is_lifetime_expired(caster, targets, 0, _times_triggered)
		):
			queue_free()


## Called when one of this Effect's Lifetimes has ended.
func on_lifetime_ended():
	pass
