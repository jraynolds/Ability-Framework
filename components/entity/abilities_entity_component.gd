extends EntityComponent
## An EntityComponent containing Abilities values and logic.
class_name AbilitiesEntityComponent

## The Abilities this Entity has, paired with the bar locations for each Ability. 
## The integer can be 0-19; 0 is "1", 10 is "+1"
var abilities : Dictionary[Ability, int]
var abilities_cast : Array[Ability] ## The heap (front-recent) of Abilities this Entity has successfully cast.

@export var ability_scene : PackedScene ## The default Ability scene.

## Overloaded method for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
## Intializes Ability objects.
func load_entity_resource(resource: EntityResource):
	abilities = {}
	for ability_resource in resource.abilities.keys():
		var ability : Ability = ability_scene.instantiate().from_resource(ability_resource, entity)
		abilities[ability] = resource.abilities[ability_resource]
		add_child(ability)
		ability.name = ability._title


## Overloaded method for logic that happens when the Entity value is updated.
func on_entity_updated():
	pass


## Casts the given ability on the given targets. Adds it to the heap of our casts.
func cast(ability: Ability, targets: Array[Entity]):
	ability.cast(targets)
	abilities_cast.insert(0, ability)


## Returns the last valid Ability cast.
func get_last_ability_cast() -> Ability:
	return get_ability_in_chain(0)


## Backtracks the Abilities this Entity has cast and returns the valid cast at the given index.
func get_ability_in_chain(chain_index: int) -> Ability:
	if len(abilities_cast) <= chain_index:
		return null
	return abilities_cast[chain_index]
