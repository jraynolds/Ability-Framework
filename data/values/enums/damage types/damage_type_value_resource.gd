extends ValueResource
## A ValueResource that returns the int value of a DamageType enum.
class_name DamageTypeValueResource

@export var damage_type : DamageEffectResource.DamageType ## The damage type we return.

## Returns the int value of our DamageType enum.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	return damage_type
