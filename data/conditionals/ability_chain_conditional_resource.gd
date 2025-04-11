extends ConditionalResource
## A ConditionalResource that checks an Entity's Ability history. Not meant to be mutated in runtime.
class_name AbilityChainConditionalResource

@export var ability_in_chain : AbilityResource ## The Ability we're checking against.
@export var ability_caster : Targeting.Target = Targeting.Target.Caster ## What Entity we're checking. By default, the caster.
@export var chain_position : ValueResource ## How many Abilities back we're checking.

## Returns whether the ability caster last cast the given Ability.
func is_met(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> bool:
	assert(ability_in_chain, "No valid AbilityResource set")
	var entity : Entity = null
	match ability_caster:
		Targeting.Target.Caster:
			entity = caster
		Targeting.Target.Target:
			assert(len(targets), "No valid Entity target")
			entity = targets[0]
	assert(entity, "No valid Entity found")
	var ability_check = entity.history_component.get_ability_history(chain_position.get_value(caster, targets))
	if !ability_check:
		return false
	return ability_check.ability.is_resource_equal(ability_in_chain)
