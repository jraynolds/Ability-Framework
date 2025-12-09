extends ConditionalResource
## A ConditionalResource that checks an Effect's Resource type. Not meant to be mutated in runtime.
class_name EffectResourceConditionalResource

## What kind of EffectResource we check the Effect's resource against.
@export var effect_resource : EffectResourceType 
enum EffectResourceType {
	Base,
	Damage,
	StatusAdd,
	StatModify
}
@export var matches : bool = true ## Whether we return true if a match is found. By default, yes.

## Returns whether the given effect is of our type.
func is_met(effect_info: EffectInfo, overrides: Dictionary={}) -> bool:
	var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	#var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
	
	match effect_resource:
		EffectResourceType.Base:
			if effect._resource as DamageEffectResource:
				return !matches
			if effect._resource as StatusAddEffectResource:
				return !matches
			if effect._resource as StatModifyEffectResource:
				return !matches
			return matches
		EffectResourceType.Damage:
			if effect._resource as DamageEffectResource:
				return matches
		EffectResourceType.StatusAdd:
			if effect._resource as StatusAddEffectResource:
				return matches
		EffectResourceType.StatModify:
			if effect._resource as StatModifyEffectResource:
				return matches
	assert(false, "Unimplemented Effect Resource")
	return false
