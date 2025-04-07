extends Resource
## A Resource that acts as an intermediate layer when a stat would be modified.
class_name TransformResource

@export var stat_type : StatResource.StatType ## The Stat we transform.
@export var math_operation : Math.Operation ## The math operation we transform.
@export var modifier : ValueResource ## The value we modify the incoming value with.
@export var subtracted_from_1 : bool ## Whether we should subtract the modifier value from 1.
@export var modifier_operation : Math.Operation ## The math operation we use to modify the incoming value.
@export var conditionals : Array[ConditionalResource] ## The conditions we check to see if we perform the Transform.

## Attempts to modify the given value. If the conditionals aren't met, just returns the incoming value.
func try_transform(value: float, effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> float:
	if !can_transform(value, effect, ability, caster, targets):
		return value
	
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


## Returns whether this Transform can be used on an incoming value.
func can_transform(value: float, effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> bool:
	for conditional in conditionals:
		if !conditional.is_met(effect, ability, caster, targets):
			return false
	return true
