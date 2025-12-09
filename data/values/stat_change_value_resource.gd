extends ValueResource
## ValueResource that returns the magnitude of the change in the target's given stat.
## Tracks backwards the given number of changes.
class_name StatChangeValueResource

## An optional override for who we target to get a stat from. If not chosen, this will be the target of the Effect.
@export var targeting_resource_override : TargetingResource 
@export var stat_resource : ValueResource ## The stat we find changes for. By default, HP.
@export var index_resource : ValueResource ## How many changes back we look. By default, none.

## Returns the magnitude of the target's previous stat change.
func calc_value(effect_info: EffectInfo, overrides: Dictionary={}):
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
	
	var stat = stat_resource.get_value_int(effect_info, overrides) as StatResource.StatType if stat_resource else StatResource.StatType.HP
	var index = index_resource.get_value_int(effect_info, overrides) if index_resource else 0
	
	var change = targets[0].history_component.get_stat_change_history(stat, index)
	
	if !change:
		return NAN
	if change.new_value == NAN or change.old_value == NAN:
		return NAN
	return change.new_value - change.old_value
