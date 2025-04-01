extends Resource
## A Resource representing an effect. Not meant to be mutated in runtime.
class_name EffectResource

@export var title : String ## The title of this Effect.
@export_multiline var description : String ## The description of this Effect.
@export var icon : Texture2D ## The icon for this Effect.
## Whether this Effect is good, bad, or neither for the target. By default, it's bad.
@export var positivity : Math.Positivity = Math.Positivity.Negative 
@export var triggers : Array[TriggerResource] ## The triggers for this Effect.
@export var conditionals_positive : Array[ConditionalResource] ## The conditionals that allow this Effect.
@export var conditionals_negative : Array[ConditionalResource] ## The conditionals that disallow this Effect.


#func on_created(effect: Effect, ability: )


func affect(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	pass
