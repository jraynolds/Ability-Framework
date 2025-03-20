extends Resource
## A Resource representing a condition. Not meant to be mutated in runtime.
class_name ConditionalResource

@export var title : String ## The title of this Condition.
@export_multiline var description : String ## The description of this Condition.


## Returns whether the conditions are met. False by default.
func is_met(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	return false
