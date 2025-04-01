extends Resource
## A Resource that transforms a given float. Not meant to be mutated in runtime.
class_name IOLayerResource

## Modifies the given float and returns it. Meant to be overloaded.
func apply_layer(input: float, effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> float:
	return -1
