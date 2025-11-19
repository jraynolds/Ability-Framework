extends TransformResource
## A TransformResource that acts as an intermediate layer for the given Stat.
class_name StatTransformResource

@export var stat_type : StatResource.StatType ## The Stat we target.

## Attempts to modify the given value. If the conditionals aren't met, just returns the incoming value.
func try_transform(value: float, effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity], stacks: int=1) -> float:
	super(value, effect, ability, caster, targets, stacks)
	
	var modifier_value = get_modifying_value(value, effect, ability, caster, targets, stacks)
	
	DebugManager.debug_log(
		"Modification of " + str(value) + " on stat " + Natives.enum_name(StatResource.StatType, stat_type) +
		" is being transformed by " + modifier_value + " using math operation " + Natives.enum_name(Math.Operation, modifier_operation) +
		" with multiplication behavior " + Natives.enum_name(Math.MultiplicationBehavior, multiplication_behavior) +
		" with multistack behavior " + Natives.enum_name(TransformResource.MultistackBehavior, multistack_behavior)
	, self)
	
	var transformed_value = Math.perform_operation(value, modifier_value, modifier_operation)
	
	DebugManager.debug_log(
		"The transformation has changed " + str(value) + " to " + str(transformed_value)
	, self)
	
	if multistack_behavior == MultistackBehavior.Recursive and stacks > 1:
		return try_transform(transformed_value, effect, ability, caster, targets, stacks-1)
	return transformed_value
