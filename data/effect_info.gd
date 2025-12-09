## Info class to store an Effect, its Ability, the Entity who cast it, and the Entities it was cast upon.
## Provides a snapshot of an Effect at the time it is first registered. Info not matching this should be provided as an override.
class_name EffectInfo

var effect : Effect ## The Effect at this moment.
var ability : Ability ## The Ability that cast the Effect, traversing down the tree.
var caster : Entity ## The caster of said Ability.
var targets : Array[Entity] ## The targets of the Ability at this moment.

## Initializes values.
func _init(e: Effect=null, a: Ability=null, c: Entity=null, t: Array[Entity]=[]):
	effect = e
	ability = a
	caster = c
	targets = t


## Outputs this information as a string.
func _to_string() -> String:
	return (
		"effect " + effect.name + " from ability " + ability._title + " from caster " + 
		caster.title + " at targets " + ",".join(targets.map(func(t: Entity): return t.title))
	)
	
