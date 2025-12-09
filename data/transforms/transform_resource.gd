extends Resource
## A Resource that acts as an intermediate layer when a number would be applied to an Entity, and modifies that number.
## Used exclusively in StatusEffects.
class_name TransformResource

@export var modifier : ValueResource ## The value we modify the incoming number with.
@export var modifier_operation : Math.Operation ## The math operation we use to modify the incoming value.
@export var multiplication_behavior : Math.MultiplicationBehavior ## The behavior for multiplication to use.
@export var multistack_behavior : MultistackBehavior ## The behavior if we have multiple stacks.
@export var conditionals : Array[ConditionalResource] ## The conditions we check to see if we perform the Transform.

enum MultistackBehavior { ## The behavior multiple stacks results in.
	Additive, ## Each stack adds its affect, then perform the transform.
	Recursive, ## Each stack performs the transform individually.
}

## Gets the modifying value. If given more than 1 stack, each stack is tallied according to the MultistackBehavior.
func get_modifying_value(
	_value: float, 
	effect_info: EffectInfo,
	overrides: Dictionary={},
	stacks: int=1
) -> float:
	var modifier_value = modifier.get_value(effect_info, overrides)
	
	assert(stacks >= 1, "No plan for negative stacks!")
	if stacks > 1:
		if multistack_behavior == MultistackBehavior.Additive:
			modifier_value *= stacks
	
	if multiplication_behavior == Math.MultiplicationBehavior.AddToOne:
		modifier_value += 1.0
	elif multiplication_behavior == Math.MultiplicationBehavior.SubtractFromOne:
		modifier_value = 1.0 - modifier_value
	
	return modifier_value


## Attempts to modify the given value. If the conditionals aren't met, just returns the incoming value.
func try_transform(value: float, effect_info: EffectInfo, overrides: Dictionary={}, _stacks: int=1) -> float:
	if !can_transform(effect_info, overrides):
		return value
	return value


## Returns whether this Transform can be used on an incoming value.
func can_transform(effect_info: EffectInfo, overrides: Dictionary={}) -> bool:
	for conditional in conditionals:
		if !conditional.is_met(effect_info, overrides):
			return false
	return true
