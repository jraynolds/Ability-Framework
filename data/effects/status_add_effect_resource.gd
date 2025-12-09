extends EffectResource
class_name StatusAddEffectResource
## An EffectResource that adds a given Effect to an Entity.

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
## The Effect scene to be created as an instance.
var status_effect_scene : PackedScene = preload("res://components/abilities/effects/status_effect.tscn")
@export var visible_status : bool = true ## Whether the StatusEffect should be visible on the GUI.

## Called when an Effect containing this Resource is created. 
## Creates an instance copy of the status Effect to be added.
func on_created(effect_info: EffectInfo, overrides: Dictionary={}):
	var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	#var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
	
	var sub_effect : StatusEffect = status_effect_scene.instantiate().from_resource(
		effect_added,
		effect_info.ability,
		effect_info.caster
	).with_expiration(
		lifetime,
		expirations
	)
	assert(sub_effect, "We couldn't make that Status effect!")
	effect.add_sub_effect(sub_effect)


## Called when an Effect containing this Resource affects targets.
## Adds the status Effect to the targets.
func on_affect(effect_info: EffectInfo, overrides: Dictionary={}):
	var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
		
	var status_effect_index = effect._sub_effects.find_custom(func(se: Effect):
		return se.has_resource(effect_added)
	)
	assert(status_effect_index >= 0, "The status effect object is gone!")
	
	var stacks = num_stacks.get_value(effect_info, overrides) if num_stacks else 1.0
	
	DebugManager.debug_log(
		"Adding a status called " + effect._sub_effects[status_effect_index]._title +
		" to the Entities " + ",".join(targets.map(func(e: Entity): return e.title)) +
		" with stacks equal to " + str(stacks)
	, self)
	
	for target in targets:
		target.statuses_component.add_status(
			effect._sub_effects[status_effect_index],
			effect_info,
			overrides,
			stacking_behavior,
			stacks
		)
