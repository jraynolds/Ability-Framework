extends ConditionalResource
## A ConditionalResource that checks an Entity's Ability history. Not meant to be mutated in runtime.
class_name AbilityChainConditionalResource

 ## An optional targeting resource to use for this conditional. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var ability_in_chain : AbilityResource ## The Ability we're checking against.
@export var chain_position : ValueResource ## How many Abilities back we're checking. If left blank, the most recent.

## Returns whether the ability caster last cast the given Ability.
func is_met(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> bool:
	assert(ability_in_chain, "No valid AbilityResource set")
	
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(caster, ability, effect)
	var ability_index = 0
	if chain_position:
		ability_index = chain_position.get_value(caster, targets)
		
	var ability_check = targets[0].history_component.get_ability_history(ability_index)
	if !ability_check:
		return false
	return ability_check.ability.is_resource_equal(ability_in_chain)
