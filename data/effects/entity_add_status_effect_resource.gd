extends EffectResource
## An EffectResource that adds to an Entity's Stat.
class_name EntityAddStatusResource

## The Entity(s) this Effect affects. By default, all valid targets.
@export var entity_target : Targeting.Target = Targeting.Target.Targets 
@export var effect : EffectResource ## The Effect this Effect adds to an Entity.
enum StackingBehavior { ## What happens if the Entity has the same Effect we're trying to add.
	Refresh = 0, ## Resets the duration.
	Ignore = 10, ## Like we didn't cast this.
	Add = 20, ## Adds a stack.
	Subtract = 21, ## Removes a stack.
	Replace = 30 ## Removes the original and adds this one.
}
## How the Effect we're adding interacts with an existing, identical Effect. By default, resets the original's duration.
@export var stacking_behavior : StackingBehavior = StackingBehavior.Refresh
 
func affect(caster: Entity, targets: Array[Entity]):
	var targets_found : Array[Entity] = []
	match entity_target :
		Targeting.Target.Targets:
			assert(targets[0], "There are no valid targets")
			for target in targets:
				targets_found.append(target)
		Targeting.Target.Target:
			assert(targets[0], "There is no valid target")
			targets_found.append(targets[0])
		Targeting.Target.Caster:
			targets_found.append(caster)
	assert(!targets_found.is_empty(), "No valid targets found")
	for target in targets_found:
		target.statuses_component.add_effect_from_resource(effect, stacking_behavior)
