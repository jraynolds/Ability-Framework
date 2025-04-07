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

## A history of Effects received by this Entity.
## Stored as heap (front-recent) of EffectHistory type, which has effect: Effect, ability: Ability and targets: Array[Entity] fields. 
var effects_received : Array[EffectHistory]
class EffectHistory:
	var effect: Effect
	var ability: Ability
	var targets: Array[Entity]

## A history of damage dealt to this Entity.
## Stored as heap (front-recent) of FloatHistory type, which has float_new: float and float_old: float fields.
## Here, float_new is how much damage we actually took; float_old is how much we were presented with. 
var damages_received : Array[FloatHistory]
class FloatHistory :
	var float_new: float
	var float_old: float

## A history of stat changes this Entity experiences.
## Stored with stat type keys and heap (front-recent) of array of FloatHistory type, which has float_new: float and float_old: float fields.
## Here, float_new is the stat value after the change; float_old is the stat value before. 
var stats_changed : Dictionary[StatResource.StatType, Array]

## Called when this node enters the scene.
## Connects signals to the other EntityComponents.
func _ready() -> void:
	entity.abilities_component.on_ability_cast.connect(
		func(ability: Ability, targets: Array[Entity]):
			abilities_cast.insert(0, AbilityHistory.new(ability, targets))
	)
	

## Overloaded method for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
func load_entity_resource(resource: EntityResource):
	abilities_cast = []
	effects_received = []
	damages_received = []
	stats_changed = {}


## Returns the last valid Ability cast.
func get_last_ability_cast() -> Ability:
	return get_ability_in_chain(0)


## Backtracks the Abilities this Entity has cast and returns the valid cast at the given index.
func get_ability_in_chain(chain_index: int) -> Ability:
	if len(abilities_cast) <= chain_index:
		return null
	return abilities_cast[chain_index].ability
