extends ConditionalResource
## A ConditionalResource that checks an Entity's Ability history. Not meant to be mutated in runtime.
class_name AbilityChainConditionalResource

 ## An optional targeting resource to use for this conditional. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var ability_in_chain : AbilityResource ## The Ability we're checking against.
@export var chain_position : ValueResource ## How many Abilities back we're checking. If left blank, the most recent.
@export var non_GCDs_break_chain : bool ## Whether Abilities off the GCD break the chain. 

## Returns whether the ability caster last cast the given Ability.
func is_met(effect_info: EffectInfo, overrides: Dictionary={}) -> bool:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
	
	DebugManager.debug_log(
		"Evaluating whether the ability caster " + caster.title + " cast the ability " + ability_in_chain.resource_path +
		" at reverse index " + str(chain_position)
		+ (" using the targeting resource override " + targeting_resource_override.resource_path) if targeting_resource_override else ""
		+ (" ignoring non-GCDs" if !non_GCDs_break_chain else " including non-GCDs")
	, self)
	assert(ability_in_chain, "No valid AbilityResource set")
	
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
	var ability_index = 0
	if chain_position:
		ability_index = chain_position.get_value(effect_info, overrides)
		
	var ability_at_index = targets[0].history_component.get_ability_history(ability_index, !non_GCDs_break_chain)
	if !ability_at_index:
		DebugManager.debug_log(
			"No ability at that index, so no."
		, self)
		return false
	var met = ability_at_index.ability.is_resource_equal(ability_in_chain)
	DebugManager.debug_log(
		"Evaluation result is " + str(met)
	, self)
	return met
