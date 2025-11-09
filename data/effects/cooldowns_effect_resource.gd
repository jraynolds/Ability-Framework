extends EffectResource
## Modifies the target's cooldowns.
class_name CooldownsEffectResource

## The Entity(s) this Effect affects. By default, all valid targets.
@export var entity_target : Targeting.Target = Targeting.Target.Targets
@export var cooldown_amount : ValueResource ## How much we should modify the target's cooldowns by. By default, 1.
@export var math_operation : Math.Operation ## The type of mathematics operation we'll perform.

## Called when an Effect containing this Resource is created. Meant to be overloaded.
func on_created(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	pass


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
	
	var cooldown_modification = cooldown_amount.get_value(caster, targets) if cooldown_amount else 1
	
	for target in targets_found:
		target.abilities_component.modify_cooldowns(cooldown_modification, math_operation)
