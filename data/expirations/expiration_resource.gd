extends Resource
## Resource for a conditional expiration on a LifetimeEffect.
class_name ExpirationResource

@export var triggers : Array[TriggerResource] ## The triggers that cause this expiration
@export var stacks_removed : ValueResource ## The amount of stacks removed from the LifetimeEffect. By default, all.

## Registers a listener to expire the Effect.
func register(effect_info: EffectInfo, overrides: Dictionary={}):
	var effect : StatusEffect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	#var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
	
	DebugManager.debug_log(
		"StatusEffect " + effect._title + "'s expiration effects are being registered to its triggers"
	, self)
	for trigger in triggers:
		trigger.register(effect_info, overrides, effect.expire_from_resource.bind(self))
		DebugManager.debug_log(
			"StatusEffect " + effect._title + "'s expiration effects have been registered to trigger " + 
			trigger.title
		, self)


## Causes the selected expiration behavior to happen for the StatusEffect.
func expire_effect(effect_info: EffectInfo, overrides: Dictionary={}):
	var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	#var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
		
	DebugManager.debug_log(
		"StatusEffect " + effect._title + "'s expiration effect is being triggered"
	, self)
	if stacks_removed:
		for target in effect._targets:
			target.statuses_component.modify_stacks(
				effect, 
				-stacks_removed.get_value_int(effect_info, overrides)
			)
	else :
		effect.end()
