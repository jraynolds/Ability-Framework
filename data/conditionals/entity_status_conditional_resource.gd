extends ConditionalResource
## A ConditionalResource that checks whether all of the given Entities has a Status, and at least n stacks of it. Not meant to be mutated in runtime.
class_name EntityStatusConditionalResource

 ## An optional targeting resource to use for this conditional. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var status : EffectResource ## The Ability we're checking against.
@export var minimum_stacks : ValueResource ## The minimum number of stacks the status must have. By default, 1.

## Returns whether the given Entity has the given Effect as a status.
func is_met(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> bool:
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(caster, ability, effect)
	
	var min_stacks : float = minimum_stacks.get_value(caster, targets) if minimum_stacks else 1
	
	for target in targets:
		var matching_status = target.statuses_component.get_status_by_resource(status)
		if !matching_status:
			return false
		if target.statuses_component.get_status_stacks(matching_status) < min_stacks:
			return false
	return true
