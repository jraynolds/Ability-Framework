extends Node
## The runtime instance of an EffectResource.
class_name Effect

var _resource : EffectResource ## The base EffectResource this Effect represents.
var _title : String ## The title of this Effect.
var _description : String ## The description of this Effect.
var _positivity : Math.Positivity ## Whether this Effect is good, bad, or neither for its target.
var _icon : Texture2D ## The icon for this Effect.
var _triggers : Array[TriggerResource] = [] ## The triggers that cause this Effect.
var _conditionals_positive : Array[ConditionalResource] = [] ## The conditionals that allow this Effect.
var _conditionals_negative : Array[ConditionalResource] = [] ## The conditionals that disallow this Effect.

var _caster : Entity ## The Entity responsible for the creation of this Effect.
var _ability : Ability ## The Ability that created this Effect.
var _targets : Array[Entity] ## The Entities targeted by this Effect.

var _sub_effects : Array[Effect] = [] ## Sub-effects this Effect also tracks.

signal on_registered ## Emitted when this Effect is fully registered on all its Triggers.
signal on_affected(caster: Entity, targets: Array[Entity]) ## Emitted when this Effect affects its targets.
signal on_unregistered ## Emitted when this Effect is fully unregistered on all its Triggers.
signal on_lifetime_ended ## Emitted when any of this Effect's lifetimes expires.
signal on_ended ## Emitted when this Effect expires.

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


## Updates this Effect's Resource with another.
func update_resource(res: EffectResource):
	_resource = res
	_title = _resource.title
	_description = _resource.description
	_positivity = _resource.positivity
	_icon = _resource.icon
	for trigger in _resource.triggers:
		_triggers.append(trigger)
	for conditional in _resource.conditionals_positive:
		_conditionals_positive.append(conditional)
	for conditional in _resource.conditionals_negative:
		_conditionals_negative.append(conditional)


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
	print("affecting " + targets[0].title + " with " + _title)
	
	for target in targets:
		_resource.on_affect(self, _ability, caster, targets)


## Adds a sub-Effect to our array and adds it as a child.
func add_sub_effect(sub_effect: Effect):
	_sub_effects.append(sub_effect)
	add_child(sub_effect)


## Returns whether the given Effect shares our same EffectResource.
func shares_resource(effect: Effect) -> bool:
	return effect._resource == _resource


## Ends this Effect.
func end():
	on_ended.emit()
	queue_free()
