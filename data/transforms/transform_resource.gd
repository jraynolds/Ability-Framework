extends Resource
## A Resource that acts as an intermediate layer when a stat would be modified.
class_name TransformResource

@export var stat_type : StatResource.StatType ## The Stat we transform.
@export var math_operation : Math.Operation ## The math operation we transform.
@export var modifier : ValueResource ## The value we modify the incoming value with.
@export var subtracted_from_1 : bool ## Whether we should subtract the modifier value from 1.
@export var modifier_operation : Math.Operation ## The math operation we use to modify the incoming value.

## Modifies the given value.
func transform(value: float, caster: Entity, targets: Array[Entity]) -> float:
	var modifier_value = modifier.get_value(caster, targets)
	if subtracted_from_1:
		modifier_value = 1 - modifier_value
	DebugManager.debug_log(
		"Transforming stat " + Natives.enum_name(StatResource.StatType, stat_type) +
		" being modified by " + str(value) + " using " + Natives.enum_name(Math.Operation, math_operation) +
		" by " + str(modifier_value) + " using " + Natives.enum_name(Math.Operation, modifier_operation)
	, self)
	var transformed_value = Math.perform_operation(value, modifier_value, modifier_operation)
	DebugManager.debug_log(
		"Stat type " + Natives.enum_name(StatResource.StatType, stat_type) + " modifier equalling " +
		str(modifier_value) + " now " + str(transformed_value)
	, self)
	return transformed_value
