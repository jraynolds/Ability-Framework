extends EffectResource
## Sets whether the targets are active or not.
class_name SetActiveEffectResource

## The Entity(s) this Effect affects. By default, all valid targets.
@export var entity_target : Targeting.Target = Targeting.Target.Targets
@export var active : ValueResource ## Whether the targets should be set to active or not. By default, active.

## Called when an Effect containing this Resource affects targets. Meant to be overloaded.
func on_affect(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	super(effect, ability, caster, targets)
	
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
			#print("Target for adding " + effect_added.title + " is caster") 
			targets_found.append(caster)
			effect._targets = [caster]
	assert(!targets_found.is_empty(), "No valid targets found")
	
	var is_active = active.get_value(caster, targets) if active else 1
	
	for target in targets_found:
		target.abilities_component.can_act = is_active
