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

## Returns whether the ability caster last cast the given Ability.
func is_met(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> bool:
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
