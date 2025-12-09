extends EntityComponent
## An EntityComponent containing a history of effects, stat changes, ability casts and so on for this Entity.
class_name HistoryEntityComponent

## A history of Abilities cast by this Entity. 
## Stored as a heap (front-recent) of AbilityHistory type, which has ability: Ability and targets: Array[Entity] field.
var abilities_cast : Array[AbilityHistory] 
class AbilityHistory:
	var ability: Ability
	var targets: Array[Entity]
	func _init(a: Ability, t: Array[Entity]):
		ability = a
		targets = t
## Abilities as cast by this Entity, but only those that are of OnGCD type.
var gcd_abilities_cast : Array[AbilityHistory] :
	get :
		return abilities_cast.filter(func(history: AbilityHistory): return history.ability._gcd_type == AbilityResource.GCD.OnGCD)

## A history of Effects received by this Entity.
## Stored as heap (front-recent) of EffectHistory type, which has effect: Effect, ability: Ability and targets: Array[Entity] fields. 
var effects_received : Array[EffectHistory]
class EffectHistory:
	var effect: Effect
	var ability: Ability
	var targets: Array[Entity]

## A history of damage dealt to this Entity.
## Stored as heap (front-recent) of DamageHistory type, which has
## damage_type: DamageEffectResource.DamageType, damage_taken: float, damage_assigned: float, and EffectInfo fields
var damages_received : Array[DamageHistory]
class DamageHistory :
	var damage_taken: float
	var damage_assigned: float
	var damage_type: DamageEffectResource.DamageType
	var damaging_effect_info : EffectInfo
	func _init(taken: float, assigned: float, type: DamageEffectResource.DamageType, info: EffectInfo):
		damage_taken = taken
		damage_assigned = assigned
		damage_type = type
		damaging_effect_info = info
enum DamageHistoryInfo {
	DamageTaken,
	DamageAssigned,
	DamageMitigated,
	DamageType,
	DamagingEffect,
	DamagingAbility,
	DamagingEntity
}

## A history of stat changes this Entity experiences.
## Stored with stat type keys and heap (front-recent) of array of FloatHistory type, which has new_value: float and old_value: float fields.
## Here, new_value is the stat value after the change; old_value is the stat value before. 
var stats_changed : Dictionary[StatResource.StatType, Array]
class FloatHistory :
	var new_value : float
	var old_value : float
	func _init(new: float, old: float):
		new_value = new
		old_value = old

## Called when this node enters the scene.
## Connects signals to the other EntityComponents.
func _ready() -> void:
	entity.abilities_component.on_ability_cast.connect(
		func(ability: Ability, targets: Array[Entity]):
			abilities_cast.insert(0, AbilityHistory.new(ability, targets))
	)
	entity.stats_component.on_stat_change.connect(
		func(stat_type: StatResource.StatType, new_value: float, old_value: float):
			if stat_type not in stats_changed:
				stats_changed[stat_type] = []
			stats_changed[stat_type].insert(0, FloatHistory.new(new_value, old_value))
	)
	entity.stats_component.on_take_damage.connect(
		func(damage_taken: float, damage_assigned: float, damage_type: DamageEffectResource.DamageType, info: EffectInfo):
			damages_received.insert(0, DamageHistory.new(damage_taken, damage_assigned, damage_type, info))
	)
	

## Overloaded method for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
func load_entity_resource(_resource: EntityResource):
	abilities_cast = []
	effects_received = []
	damages_received = []
	stats_changed = {}


## Backtracks the Abilities this Entity has cast and returns the valid history at the given index.
## Optionally, ignores Abilities that are off the GCD.
## By default, returns the most recent.
func get_ability_history(heap_index: int = 0, ignore_non_gcd=false) -> AbilityHistory:
	var heap = abilities_cast
	if ignore_non_gcd:
		heap = gcd_abilities_cast
	if len(heap) <= heap_index:
		return null
	return heap[heap_index]


## Backtracks the damage this Entity has received and returns the valid history at the given index.
## By default, returns the most recent.
func get_damage_history(heap_index: int = 0) -> DamageHistory:
	if len(damages_received) <= heap_index:
		return null
	return damages_received[heap_index]


## Backtracks the stat changes this Entity has received and returns the valid history at the given index for the given stat.
## By default, returns the most recent.
func get_stat_change_history(stat: StatResource.StatType, heap_index: int = 0) -> FloatHistory:
	if len(stats_changed[stat]) <= heap_index:
		return null
	return stats_changed[stat][heap_index]
