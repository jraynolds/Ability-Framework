extends EntityComponent
## An EntityComponent containing Stats values and logic.
class_name StatsEntityComponent

## Emitted when a Stat we're tracking changes
signal on_stat_change(stat: StatResource.StatType, new_val: float, old_val: float)

func get_stat_value(stat: StatResource.StatType) -> float:
	return -1

func get_stat_value_by_resource(stat: StatResource) -> float:
	return get_stat_value(stat.type)
