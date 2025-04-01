extends EffectResource
## An EffectResource that adds a given Effect to an Entity.
class_name AddStatusEffectResource

## The Entity(s) this Effect affects. By default, all valid targets.
@export var entity_target : Targeting.Target = Targeting.Target.Targets 
@export var effect_added : EffectResource ## The Effect this Effect adds to an Entity.
enum StackingBehavior { ## What happens if the Entity has the same Effect we're trying to add.
	Refresh = 0, ## Resets the duration.
	Ignore = 10, ## Like we didn't cast this.
	Add = 20, ## Adds a stack.
	AddAndRefresh = 21, ## Adds a stack and resets the duration.
	AddAndReplace = 22, ## Adds a stack and replaces the effect.
	Subtract = 30, ## Removes a stack.
	Replace = 40 ## Removes the original and adds this one.
}
## How the Effect we're adding interacts with an existing, identical Effect. By default, resets the original's duration.
@export var stacking_behavior : StackingBehavior = StackingBehavior.Refresh
@export var lifetimes : Array[LifetimeResource] ## The lifetimes before the added Effect expires.
enum ExpirationBehavior { ## What should happen when the Effect reaches the end of a Lifetime.
	Subtract = 0, ## A multi-stack ticks down by 1, and is erased if the stack number becomes 0.
	Erase = 10, ## Just takes the entire Effect away.
}
@export var expiration_behavior : ExpirationBehavior = ExpirationBehavior.Subtract
 
func affect(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
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
	for target in targets_found:
		target.statuses_component.add_effect_from_resource(effect_added, ability, caster, stacking_behavior, lifetimes, expiration_behavior)
