extends EntityComponent
## An EntityComponent containing Abilities values and logic.
class_name AbilitiesEntityComponent


## Returns the last valid Ability cast.
func get_last_ability_cast() -> Ability:
	return get_ability_in_chain(0)


## Backtracks the Abilities this Entity has cast and returns the valid cast at the given index.
func get_ability_in_chain(chain_index: int) -> Ability:
	return null
