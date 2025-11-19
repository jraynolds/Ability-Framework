extends TransformEffectResource
## A TransformResource that acts as an intermediate layer for the given keyword.
class_name KeywordTransformEffectResource

@export var keyword : Keyword ## The keyword we target.
enum Keyword {
	Damaged, ## Damage dealt to this Entity.
	Damage, ## Damage dealt by this Entity.
	Healing, ## Healing given to an Entity.
}

## Attempts to modify the given value. If the conditionals aren't met, just returns the incoming value.
func try_transform(value: float, effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity], stacks: int=1) -> float:
	if !can_transform(value, effect, ability, caster, targets):
		return value
	
	var modifier_value = get_modifying_value(value, effect, ability, caster, targets, stacks)
	
	DebugManager.debug_log(
		"Modification of " + str(value) + " on keyword " + Natives.enum_name(Keyword, keyword) +
		" is being transformed by " + str(modifier_value) + " using math operation " + Natives.enum_name(Math.Operation, modifier_operation) +
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
