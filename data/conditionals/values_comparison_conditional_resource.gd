extends ConditionalResource
## A ConditionalResource that compares two values. Not meant to be mutated in runtime.
class_name ValuesComparisonConditionalResource

@export var value_1 : ValueResource ## The value we're comparing.
@export var value_2 : ValueResource ## The value we're checking against.
@export var comparison : Math.Comparison = Math.Comparison.Equal ## The math comparison we're undertaking. By default, equality.

## Returns whether our comparison (e.g., "Equal") is true for our values.
func is_met(effect_info: EffectInfo, overrides: Dictionary={}) -> bool:
	DebugManager.debug_log(
		"Comparing the two values " + value_1.resource_path + " and " + value_2.resource_path + " with the comparison " +
		Natives.enum_name(Math.Comparison, comparison)
	, self)
	
	var met = false
	match comparison:
		Math.Comparison.Equal:
			met = value_1.get_value(effect_info, overrides) == value_2.get_value(effect_info, overrides)
		Math.Comparison.GreaterThan:
			met = value_1.get_value(effect_info, overrides) > value_2.get_value(effect_info, overrides)
		Math.Comparison.GreaterThanOrEqual:
			met = value_1.get_value(effect_info, overrides) >= value_2.get_value(effect_info, overrides)
		Math.Comparison.LessThan:
			met = value_1.get_value(effect_info, overrides) < value_2.get_value(effect_info, overrides)
		Math.Comparison.LessThanOrEqual:
			met = value_1.get_value(effect_info, overrides) <= value_2.get_value(effect_info, overrides)
	DebugManager.debug_log(
		"The comparison has evaluated as " + str(met)
	, self)
	return met
