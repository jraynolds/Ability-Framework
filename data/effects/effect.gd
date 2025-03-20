extends Node
## The runtime instance of an EffectResource.
class_name Effect

var _resource : EffectResource ## The base EffectResource this Effect represents.
var _title : String ## The title of this Effect.
var _description : String ## The description of this Effect.
var _icon : Texture2D ## The icon for this Effect.
var _triggers : Array[TriggerResource] = [] ## The triggers that cause this Effect.
var _lifetimes : Array[Lifetime] ## The lifetimes before this Effect expires.
var _conditionals_positive : Array[ConditionalResource] = [] ## The conditionals that allow this Effect.
var _conditionals_negative : Array[ConditionalResource] = [] ## The conditionals that disallow this Effect.

signal on_registered ## Emitted when this Effect is fully registered on all its Triggers.
signal on_affected(caster: Entity, targets: Array[Entity]) ## Emitted when this Effect affects its targets.
signal on_unregistered ## Emitted when this Effect is fully unregistered on all its Triggers.
signal on_ended ## Emitted when this Effect expires.

## Returns an instance of this initialized with the given EffectResource.
func from_resource(resource: EffectResource) -> Effect:
	_resource = resource
	_title = resource.title
	_description = resource.description
	_icon = resource.icon
	for trigger in resource.triggers:
		_triggers.append(trigger)
	for lifetime in resource.lifetimes:
		_lifetimes.append(Lifetime.new().from_resource(lifetime))
	for conditional in resource.conditionals_positive:
		_conditionals_positive.append(conditional)
	for conditional in resource.conditionals_negative:
		_conditionals_negative.append(conditional)
	return self


## Registers this effect on the appropriate triggers.
func register(ability: Ability, caster: Entity, targets: Array[Entity]):
	assert(targets[0], "No valid targets to register on")
	for conditional in _conditionals_positive:
		if !conditional.is_met(self, ability, caster, targets):
			return
	for conditional in _conditionals_negative:
		if conditional.is_met(self, ability, caster, targets):
			return
	for trigger in _triggers:
		trigger.register(self, ability, caster, targets, on_triggered)


## Performs this Effect on the given targets, from the given caster.
func affect(caster: Entity, targets: Array[Entity]):
	for target in targets:
		_resource.affect(caster, targets)


## Called when one of this Effect's Triggers is reached.
func on_triggered():
	pass


## Called when one of this Effect's Lifetimes has ended.
func on_lifetime_ended():
	pass
