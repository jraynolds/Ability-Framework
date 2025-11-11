extends ValueResource
## A ValueResource gathered from the target Entity's number of stacks for the matching status.
class_name StatusStocksValueResource

 ## An optional targeting resource to use for this value getter. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var status : EffectResource ## The Status we're checking stacks for.

## Returns the number of stacks the given Entity has for the matching StatusEffect.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(caster)
	
	var matching_status = targets[0].statuses_component.get_status_by_resource(status)
	if matching_status:
		return targets[0].statuses_component.get_status_stacks(matching_status)
	return NAN
