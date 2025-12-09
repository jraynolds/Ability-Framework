extends ValueResource
class_name ComputedValueResource
## A ValueResource that returns the result of a series of ValueResources, combined using the given math operation.

@export var values : Array[ValueResource] ## The values that will be combined.
## The math operation that will be used to combine the values. By default, multiplication.
@export var math_operation : Math.Operation = Math.Operation.Multiplication

## Returns a value calculated from our values, combined with our operation.
func calc_value(effect_info: EffectInfo, overrides: Dictionary={}) -> float:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	#var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
		
	assert(!values.is_empty(), "There are no values for us to calculate!")
	DebugManager.debug_log(
		"Computing the values " + (",".join(values.map(func(v: ValueResource): return v.get_value(effect_info, overrides)))) + 
		" with the math operation " + Natives.enum_name(Math.Operation, math_operation)
	, self)
	
	var end_value = values[0].get_value(effect_info, overrides)
	for i in range(len(values)):
		if i == 0:
			continue
		end_value = Math.perform_operation(end_value, values[i].get_value(effect_info, overrides), math_operation)
	
	DebugManager.debug_log(
		"End value is " + str(end_value)
	, self)
	return end_value
