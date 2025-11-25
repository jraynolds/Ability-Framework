extends ConditionalResource
## A ConditionalResource that compares two values. Not meant to be mutated in runtime.
class_name ValuesComparisonConditionalResource

@export var value_1 : ValueResource ## The value we're comparing.
@export var value_2 : ValueResource ## The value we're checking against.
@export var comparison : Math.Comparison = Math.Comparison.Equal ## The math comparison we're undertaking. By default, equality.

## Returns whether the ability caster last cast the given Ability.
func is_met(_effect: Effect, _ability: Ability, caster: Entity, targets: Array[Entity]) -> bool:
	DebugManager.debug_log(
		"Comparing the two values " + value_1.resource_path + " and " + value_2.resource_path + " with the comparison " +
		Natives.enum_name(Math.Comparison, comparison)
	, self)
	
	var met = false
	match comparison:
		Math.Comparison.Equal:
			met = value_1.get_value(caster, targets) == value_2.get_value(caster, targets)
		Math.Comparison.GreaterThan:
			met = value_1.get_value(caster, targets) > value_2.get_value(caster, targets)
		Math.Comparison.GreaterThanOrEqual:
			met = value_1.get_value(caster, targets) >= value_2.get_value(caster, targets)
		Math.Comparison.LessThan:
			met = value_1.get_value(caster, targets) < value_2.get_value(caster, targets)
		Math.Comparison.LessThanOrEqual:
			met = value_1.get_value(caster, targets) <= value_2.get_value(caster, targets)
	DebugManager.debug_log(
		"The comparison has evaluated as " + str(met)
	, self)
	return met
