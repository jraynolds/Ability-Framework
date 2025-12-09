extends EffectResource
## Modifies the target's cooldowns.
class_name CooldownsEffectResource

@export var cooldown_amount : ValueResource ## How much we should modify the target's cooldowns by.
@export var math_operation : Math.Operation ## The type of mathematics operation we'll perform.

## Called when an Effect containing this Resource is created. Meant to be overloaded.
func on_created(_effect_info: EffectInfo, _overrides: Dictionary={}):
	pass


## Called when an Effect containing this Resource affects targets. Meant to be overloaded.
func on_affect(effect_info: EffectInfo, overrides: Dictionary={}):
	#super(effect_info, overrides)
	#var effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster = overrides.caster if "caster" in overrides else effect_info.caster
	var targets = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
	
	var cooldown_modification = cooldown_amount.get_value(effect_info, overrides)
	
	for target in targets:
		target.abilities_component.modify_cooldowns(cooldown_modification, math_operation)
