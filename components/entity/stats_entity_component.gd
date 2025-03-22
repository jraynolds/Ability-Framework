extends EntityComponent
## An EntityComponent containing Stats values and logic.
class_name StatsEntityComponent

@export var stat_scene : PackedScene ## The default Stat scene.
var stats : Dictionary[StatResource.StatType, Stat] ## The Entity's stats, paired with the kind of Stat each is.

## Emitted when a Stat we're tracking changes
signal on_stat_change(stat: StatResource.StatType, new_val: float, old_val: float)


## Overloaded method for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
## Intializes Stat objects.
func load_entity_resource(resource: EntityResource):
	stats = {}
	for stat_resource in resource.stats.keys():
		var stat : Stat = stat_scene.instantiate().from_resource(
			stat_resource, 
			resource.stats[stat_resource].get_value(entity, [])
		)
		stats[stat._type] = stat
		stat.name = Natives.enum_name(StatResource.StatType, stat._type)
		add_child(stat)
		stat.on_value_change.connect(func(new_val: float, old_val: float):
			on_stat_change.emit(stat._type, new_val, old_val)
		)


## Overloaded method for logic that happens when the Entity value is updated.
func on_entity_updated():
	pass


## Returns the value of a stat of the given type.
func get_stat_value(stat: StatResource.StatType) -> float:
	return stats[stat].value


## Returns the value of a stat of the given resource.
func get_stat_value_by_resource(stat: StatResource) -> float:
	return get_stat_value(stat.type)


func add_stat_value(stat: StatResource.StatType, addition: float) -> float:
	stats[stat].add_value(addition)
	return stats[stat].get_value()
