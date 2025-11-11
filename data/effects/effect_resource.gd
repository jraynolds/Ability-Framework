extends Resource
class_name EffectResource
## A Resource representing an effect. Not meant to be mutated in runtime.

@export var title : String ## The title of this Effect.
@export_multiline var description : String ## The description of this Effect.
@export var icon : Texture2D ## The icon for this Effect.
## Whether this Effect is good, bad, or neither for the target. By default, it's bad.
@export var positivity : Math.Positivity = Math.Positivity.Negative 
@export var targeting_override : TargetingResource ## An optional override for whom this effect affects.
@export var triggers : Array[TriggerResource] ## The triggers for this Effect.
@export var conditionals_positive : Array[ConditionalResource] ## The conditionals that allow this Effect.
@export var conditionals_negative : Array[ConditionalResource] ## The conditionals that disallow this Effect.

## Called when an Effect containing this Resource is created. Meant to be overloaded.
func on_created(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	pass


## Called when an Effect containing this Resource affects targets. Meant to be overloaded.
func on_affect(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	pass
