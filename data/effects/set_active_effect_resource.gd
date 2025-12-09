extends EffectResource
## Sets whether the targets are active or not.
class_name SetActiveEffectResource

@export var active_resource : ValueResource ## Whether the targets should be set to active or not. By default, active.

## Called when an Effect containing this Resource affects targets. Meant to be overloaded.
func on_affect(effect_info: EffectInfo, overrides: Dictionary={}):
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
	
	var active = active_resource.get_value(effect_info, overrides) if active_resource else 1.0
	
	DebugManager.debug_log(
		"Setting the following Entities " + ("active: " if active else "inactive: ") + 
		",".join(targets.map(func(t: Entity): return t.title))
	, self)
	
	assert(!targets.is_empty(), "There are no valid targets!")
	
	assert(false)
	#for target in targets:
		#target.abilities_component.can_act = active
