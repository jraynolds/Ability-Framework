extends EntityComponent
## An EntityComponent containing Stats values and logic.
class_name StatsEntityComponent

@export var stat_scene : PackedScene ## The default Stat scene.
var stats : Dictionary[StatResource.StatType, Stat] ## The Entity's stats, paired with the kind of Stat each is.

## An Array of Transforms that alter modifications made to stats.
var transform_statuses : Array[StatusEffect] :
	get :
		if !entity or !entity.statuses_component: return []
		return entity.statuses_component.statuses.filter(func(status: StatusEffect):
			if status._resource as TransformEffectResource:
				return true
		)

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
## By default, applies the modifications of any ongoing status Effects.
func get_stat_value(stat: StatResource.StatType, ignore_statuses: bool = false) -> float:
	DebugManager.debug_log(
		"Returning the value of stat " + Natives.enum_name(StatResource.StatType, stat) +
		(" ignoring statuses" if ignore_statuses else "")
	, self)
	if ignore_statuses:
		DebugManager.debug_log(
			"The value of stat " + Natives.enum_name(StatResource.StatType, stat) +
			" is " + str(stats[stat].value)
		, self)
		return stats[stat].value
	else :
		var stat_value = stats[stat].value
		for effect in entity.statuses_component.statuses:
			## Skip any Effects without OnGetStatValue triggers.
			if !effect._triggers.any(func(trigger: TriggerResource): 
				return trigger.trigger == TriggerResource.Trigger.OnGetStatValue
			):
				continue
			## Skip any Effects without StatModifyEffectResource.
			var stat_resource = effect._resource as StatModifyEffectResource
			if !stat_resource:
				continue
			## Skip any StatAddEffectResource without this stat as the one it modifies
			if stat_resource.stat_type != stat:
				continue
			for i in range(entity.statuses_component.status_stacks[effect]):
				stat_value = stat_resource.get_modified_value(
					stat_value, 
					effect._ability._caster,
					[entity]
				)
		DebugManager.debug_log(
			"The value of stat " + Natives.enum_name(StatResource.StatType, stat) +
			" is " + str(stat_value)
		, self)
		return stat_value


### Returns the value of a stat of the given resource.
#func get_stat_value_by_resource(stat: StatResource, bypass_statuses: bool = false) -> float:
	#return get_stat_value(stat.type, bypass_statuses)


## Modifies the given stat type by the given value, using the given math operation, performed by the given Effect.
## Optionally, bypasses all statuses to read the base stat directly.
## Optionally, bypasses all transforms to modify the base stat directly.
func modify_stat_value(
	stat: StatResource.StatType, 
	value_modifier: float,
	effect : Effect,
	math_operation: Math.Operation = Math.Operation.Addition, 
	ignore_statuses: bool = false,
	ignore_transforms: bool = false
) -> float:
	DebugManager.debug_log(
		"Modifying stat " + Natives.enum_name(StatResource.StatType, stat) +
		" by " + str(value_modifier) + " using " + Natives.enum_name(Math.Operation, math_operation) +
		" from effect " + effect.name +
		(" ignoring statuses " if ignore_statuses else "") +
		(" ignoring transforms " if ignore_transforms else "")
	, self)
	var stat_value = get_stat_value(stat, ignore_statuses)
	if !ignore_transforms:
		for transform in transform_statuses:
			if transform._resource.stat_type == stat:
				if transform._resource.math_operation == math_operation:
					value_modifier = transform.try_transform(
						value_modifier, 
						effect, 
						effect._ability, 
						effect._ability._caster, 
						[entity]
					)
	return set_stat_value(stat, Math.perform_operation(stat_value, value_modifier, math_operation))


## Sets the base value of the given stat type to the given value.
func set_stat_value(stat: StatResource.StatType, value: float) -> float:
	#print("Setting " + entity.title + "'s " + Natives.enum_name(StatResource.StatType, stat) + " to " + str(value))
	stats[stat].set_value(value)
	return stats[stat].get_value()


## Reduces the Entity's HP by the given amount, with the given type. Optionally, bypasses statuses or transforms.
## Optionally, ignores Defense, which reduces incoming damage.
func take_damage(
	damage_dealt: float, 
	damage_type: DamageEffectResource.DamageType, 
	effect: Effect, 
	ignore_statuses: bool = false,
	ignore_transforms: bool = false,
	bypass_defense: bool = false
) -> float:
	DebugManager.debug_log(
		"Taking damage equal to " + str(damage_dealt) + 
		" of type " + Natives.enum_name(DamageEffectResource.DamageType, damage_type) +
		" from effect " + effect.name +
		(" ignoring statuses " if ignore_statuses else "") +
		(" ignoring transforms " if ignore_transforms else "")
	, self)
	assert(damage_dealt >= 0, "Dealing negative damage.")
	if !bypass_defense:
		var defense = get_stat_value(StatResource.StatType.Defense, ignore_statuses)
		damage_dealt *= (1 - defense)
		DebugManager.debug_log(
			"Our defense of " + str(defense) + " has reduced the incoming damage to " + str(damage_dealt)
		, self)
	var hp_value = get_stat_value(StatResource.StatType.HP, ignore_statuses)
	if !ignore_transforms:
		for transform in transform_statuses:
			if transform._resource.stat_type == StatResource.StatType.HP:
				if transform._resource.math_operation == Math.Operation.Subtraction:
					damage_dealt = transform.try_transform(
						damage_dealt, 
						effect, 
						effect._ability, 
						effect._ability._caster, 
						[entity]
					)
	return set_stat_value(
		StatResource.StatType.HP, 
		Math.perform_operation(hp_value, damage_dealt, Math.Operation.Subtraction)
	)
