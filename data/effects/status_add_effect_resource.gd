extends EffectResource
## An EffectResource that adds a given Effect to an Entity.
class_name StatusAddEffectResource

## The Entity(s) this Effect affects. By default, all valid targets.
@export var entity_target : Targeting.Target = Targeting.Target.Targets 
@export var effect_added : EffectResource ## The Effect this Effect adds to an Entity.
enum StackingBehavior { ## What happens if the Entity has the same Effect we're trying to add.
	Refresh = 0, ## Resets the duration.
	Ignore = 10, ## Like we didn't cast this.
	Add = 20, ## Adds a stack.
	AddAndRefresh = 21, ## Adds a stack and resets the duration.
	AddAndReplace = 22, ## Adds a stack and replaces the effect.
	Subtract = 30, ## Removes stacks.
	Replace = 40 ## Removes the original and adds this one.
}
## How the Effect we're adding interacts with an existing, identical Effect. By default, resets the original's duration.
@export var stacking_behavior : StackingBehavior = StackingBehavior.Refresh
@export var num_stacks : ValueResource ## How many stacks we add. By default, 1.
@export var lifetime : ValueResource ## The duration before the added Effect expires. Time never expires it.
@export var expirations : Array[ExpirationResource] ## Triggers that cause this effect to end before its lifetime.
@export var status_effect_scene : PackedScene ## The Effect scene to be created as an instance.
@export var visible_status : bool = true ## Whether the StatusEffect should be visible on the GUI.

## Called when an Effect containing this Resource is created. 
## Creates an instance copy of the status Effect to be added.
func on_created(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	var sub_effect : StatusEffect = status_effect_scene.instantiate().from_resource(
		effect_added, 
		ability, 
		caster, 
		targets
	).with_expiration(
		lifetime,
		expirations
	)
	assert(sub_effect, "We couldn't make that Status effect!")
	effect.add_sub_effect(sub_effect)


## Called when an Effect containing this Resource affects targets.
## Adds the status Effect to the targets.
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
	var status_effect_index = effect._sub_effects.find_custom(func(se: Effect):
		return se.has_resource(effect_added)
	)
	assert(status_effect_index >= 0, "The status effect object is gone!")
	
	var stacks = num_stacks.get_value(caster, targets) if num_stacks else 1
	
	for target in targets_found:
		target.statuses_component.add_status(
			effect._sub_effects[status_effect_index],
			effect,
			ability,
			caster,
			stacking_behavior,
			stacks
		)
