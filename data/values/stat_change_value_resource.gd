extends ValueResource
## ValueResource that returns the magnitude of the change in the target's given stat.
## Tracks backwards the given number of changes.
class_name StatChangeValueResource

@export var target_resource : ValueResource ## What Entity we should be checking. By default, the caster.
@export var stat_resource : ValueResource ## The stat we find changes for. By default, HP.
@export var index_resource : ValueResource ## How many changes back we look. By default, none.

## Returns the magnitude of the target's previous stat change.
func get_value(caster: Entity, targets: Array[Entity]):
	var target = target_resource.get_value(caster, targets) if target_resource else Targeting.Target.Caster
	var stat = stat_resource.get_value(caster, targets) if stat_resource else StatResource.StatType.HP
	var index = index_resource.get_value(caster, targets) if index_resource else 0
	
	var entity = caster
	if target == Targeting.Target.Target:
		entity = targets[0]
	elif target == Targeting.Target.Targets:
		assert(false, "No plan for multiple targets.")
	assert(entity != null, "No entity to check stat changes for!")
	
	var change = entity.history_component.get_stat_change_history(stat, index)
	if !change:
		return NAN
	if change.new_value == NAN or change.old_value == NAN:
		return NAN
	return change.new_value - change.old_value
