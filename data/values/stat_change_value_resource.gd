extends ValueResource
## ValueResource that returns the magnitude of the change in the target's given stat.
## Tracks backwards the given number of changes.
class_name StatChangeValueResource

## An optional override for who we target to get a stat from. If not chosen, this will be the target of the Effect.
@export var targeting_resource_override : TargetingResource 
@export var stat_resource : ValueResource ## The stat we find changes for. By default, HP.
@export var index_resource : ValueResource ## How many changes back we look. By default, none.

## Returns the magnitude of the target's previous stat change.
func get_value(caster: Entity, targets: Array[Entity]):
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(caster)
	
	var stat = stat_resource.get_value_int(caster, targets) as StatResource.StatType if stat_resource else StatResource.StatType.HP
	var index = index_resource.get_value_int(caster, targets) if index_resource else 0
	
	var change = targets[0].history_component.get_stat_change_history(stat, index)
	
	if !change:
		return NAN
	if change.new_value == NAN or change.old_value == NAN:
		return NAN
	return change.new_value - change.old_value
