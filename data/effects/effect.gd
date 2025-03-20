extends Node
## The runtime instance of an EffectResource.
class_name Effect

var _resource : EffectResource ## The base EffectResource this Effect represents.
var _title : String ## The title of this Effect.
var _description : String ## The description of this Effect.
var _icon : Texture2D ## The icon for this Effect.
var _triggers : Array[TriggerResource] = [] ## The triggers that cause this Effect.
var _lifetime : Lifetime ## The lifetime before this Effect expires.
var _conditionals : Array[ConditionalResource] = [] ## The conditionals that allow this Effect.

## Returns an instance of this initialized with the given EffectResource.
func from_resource(resource: EffectResource) -> Effect:
	_resource = resource
	_title = resource.title
	_description = resource.description
	_icon = resource.icon
	for trigger in resource.triggers:
		_triggers.append(trigger)
	_lifetime = Lifetime.new().from_resource(resource.lifetime)
	for conditional in resource.conditionals:
		_conditionals.append(conditional)
	return self


## Registers this effect on the appropriate triggers.
func register(ability: Ability, caster: Entity, targets: Array[Entity]):
	assert(targets[0], "No valid targets to register on")
	for conditional in _conditionals:
		if !conditional.is_met(self, ability, caster, targets):
			return
	for trigger in _triggers:
		trigger.register(self, ability, caster, targets, on_triggered)


## Performs this Effect on the given targets, from the given caster.
func affect(caster: Entity, targets: Array[Entity]):
	for target in targets:
		_resource.affect(caster, targets)


func on_triggered():
	pass
