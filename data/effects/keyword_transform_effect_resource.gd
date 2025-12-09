extends TransformEffectResource
## A TransformResource that acts as an intermediate layer for the given keyword.
class_name KeywordTransformEffectResource

@export var keyword : Keyword ## The keyword we target.
enum Keyword {
	Damaged, ## Damage dealt to this Entity.
	Damage, ## Damage dealt by this Entity.
	Healing, ## Healing given to an Entity.
	CanAct, ## Whether the Entity can act.
	Targetable, ## Whether the Entity is targetable.
}

## Attempts to modify the given value. If the conditionals aren't met, just returns the incoming value.
func try_transform(value: float, effect_info: EffectInfo, overrides: Dictionary={}, stacks: int=1) -> float:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
		
	if !can_transform(value, effect_info, overrides, stacks):
		return value
	
	var modifier_value = get_modifying_value(value, effect_info, overrides, stacks)
	
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
		return try_transform(transformed_value, effect_info, overrides, stacks-1)
	return transformed_value
