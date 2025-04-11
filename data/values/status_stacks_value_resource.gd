extends ValueResource
## A ValueResource gathered from the target Entity's number of stacks for the matching status.
class_name StatusStocksValueResource

@export var target : Targeting.Target ## What Entity we should be checking.
@export var status : EffectResource ## The Status we're checking stacks for.

## Returns the number of stacks the given Entity has for the matching StatusEffect.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	var entity = caster
	if target == Targeting.Target.Target:
		entity = targets[0]
	elif target == Targeting.Target.Targets:
		assert(false, "No plan for multiple targets.")
	assert(entity != null, "No entity to check statuses for!")
	var status = entity.statuses_component.get_status_by_resource(status)
	if status:
		return entity.statuses_component.get_status_stacks(status)
	return NAN
