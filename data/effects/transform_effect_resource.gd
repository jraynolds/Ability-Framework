extends EffectResource
## An Effect that acts as an intermediate layer when a number would be applied to an Entity, and modifies that number.
## If intermediate to getter calls, it modifies the returned value. If intermediate to value changes, it modifies the changing value.
## Used exclusively in StatusEffects.
class_name TransformEffectResource

@export var modifier : ValueResource ## The value we modify the incoming number with.
@export var modifier_operation : Math.Operation ## The math operation we use to modify the incoming value.
@export var multiplication_behavior : Math.MultiplicationBehavior ## The behavior for multiplication to use.
@export var multistack_behavior : MultistackBehavior ## The behavior if we have multiple stacks.
@export var conditionals : Array[ConditionalResource] ## The conditions we check to see if we perform the Transform.

enum MultistackBehavior { ## The behavior multiple stacks results in.
	Additive, ## Each stack adds its affect, then perform the transform.
	Recursive, ## Each stack performs the transform individually.
}


## Called when an Effect containing this Resource is created.
func on_created(_effect_info: EffectInfo, _overrides: Dictionary={}):
	pass


## Called when an Effect containing this Resource affects targets.
## Does nothing. Our only use is as a StatusEffect.
func on_affect(_effect_info: EffectInfo, _overrides: Dictionary={}):
	pass


## Gets the modifying value. If given more than 1 stack, each stack is tallied according to the MultistackBehavior.
func get_modifying_value(_value: float, effect_info: EffectInfo, overrides: Dictionary={}, stacks=1) -> float:
	var modifier_value = modifier.get_value(effect_info, overrides)
	
	assert(stacks >= 0, "No plan for negative stacks!")
	assert(stacks > 0, "No plan for zero stacks!")
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
	if !can_transform(value, effect_info, overrides):
		return value
	return value


## Returns whether this Transform can be used on an incoming value.
func can_transform(_value: float, effect_info: EffectInfo, overrides: Dictionary={}, _stacks: int=1) -> bool:
	for conditional in conditionals:
		if !conditional.is_met(effect_info, overrides):
			return false
	return true
