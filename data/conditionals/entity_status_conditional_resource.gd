extends ConditionalResource
## A ConditionalResource that checks whether all of the given Entities has a Status, and at least n stacks of it. Not meant to be mutated in runtime.
class_name EntityStatusConditionalResource

 ## An optional targeting resource to use for this conditional. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var status : EffectResource ## The Effect we're checking against.
@export var minimum_stacks : ValueResource ## The minimum number of stacks the status must have. By default, 1.

## Returns whether the given Entity has our status.
func is_met(effect_info: EffectInfo, overrides: Dictionary={}) -> bool:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
	
	var min_stacks : float = minimum_stacks.get_value(effect_info) if minimum_stacks else 1.0
		
	DebugManager.debug_log(
		"Evaluating whether all of the following entities: " + ",".join(targets.map(func(t: Entity): return t.title)) + "," +
		"have the given Effect " + status.title + " as a status with at least " +
		str(min_stacks) + " stacks"
	, self)
	
	
	for target in targets:
		var matching_status = target.statuses_component.get_status_by_resource(status)
		if !matching_status:
			DebugManager.debug_log(
				"We don't have that status."
			, self)
			return false
		if target.statuses_component.get_status_stacks(matching_status) < min_stacks:
			DebugManager.debug_log(
				"We do have that status, but not with the requisite number of stacks."
			, self)
			return false
	DebugManager.debug_log(
		"We do have that status with the requisite number of stacks!"
	, self)
	return true
