extends ConditionalResource
## A ConditionalResource that checks whether the given Entity has a Status. Not meant to be mutated in runtime.
class_name EntityStatusConditionalResource

@export var status : EffectResource ## The Ability we're checking against.
@export var status_entity : Targeting.Target = Targeting.Target.Caster ## What Entity we're checking. By default, the caster.
@export var minimum_stacks : ValueResource ## The minimum number of stacks the status must have. By default, 1.

## Returns whether the given Entity has the given Effect as a status.
func is_met(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> bool:
	var entities : Array[Entity] = []
	match status_entity:
		Targeting.Target.Caster:
			entities.append(caster)
		Targeting.Target.Target:
			assert(!targets.is_empty(), "No valid Entity target")
			entities.append(targets[0])
		Targeting.Target.Targets:
			assert(!targets.is_empty(), "No valid Entity targets")
			entities.append_array(targets)
	assert(!entities.is_empty(), "No valid Entity found")
	
	var min_stacks : float = minimum_stacks.get_value(caster, targets) if minimum_stacks else 1
	
	for entity in entities:
		var matching_status = entity.statuses_component.get_status_by_resource(status)
		if !matching_status:
			return false
		if entity.statuses_component.get_status_stacks(matching_status) < min_stacks:
			return false
	return true
