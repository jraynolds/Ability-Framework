extends Resource
## A Resource representing an effect. Not meant to be mutated in runtime.
class_name EffectResource

@export var title : String ## The title of this Effect.
@export_multiline var description : String ## The description of this Effect.
@export var icon : Texture2D ## The icon for this Effect.
@export var triggers : Array[TriggerResource] ## The triggers for this Effect.
@export var conditionals : Array[ConditionalResource] ## The conditions for this Effect to take place.

func affect(caster: Entity, targets: Array[Entity]):
	pass
