extends Resource
## A Resource representing a condition. Not meant to be mutated in runtime.
class_name ConditionalResource

@export var title : String ## The title of this Condition.
@export_multiline var description : String ## The description of this Condition.


## Returns whether the conditions are met for the given effect info snapshot and any overrides. False by default.
func is_met(_effect_info: EffectInfo, _overrides: Dictionary={}) -> bool:
	return false
