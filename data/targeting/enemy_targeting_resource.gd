extends TargetingResource
class_name EnemyTargetingResource
## Base class for a resource that, given the caster, its enemies as targets.

## Returns the caster as its target.
func get_targets(caster: Entity, ability: Ability=null, effect=null) -> Array[Entity]:
	return [GameManager.battle.enemy]
