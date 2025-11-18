extends EffectResource
## Sets whether the targets are active or not.
class_name SetActiveEffectResource

@export var targeting_resource_override : TargetingResource ## An optional targeter to override what Entities are affected.
@export var active_resource : ValueResource ## Whether the targets should be set to active or not. By default, active.

## Called when an Effect containing this Resource affects targets. Meant to be overloaded.
func on_affect(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(caster, ability, effect)
	
	var active = active_resource.get_value(caster, targets) if active_resource else 1.0
	
	DebugManager.debug_log(
		"Setting the following Entities " + ("active: " if active else "inactive: ") + 
		",".join(targets.map(func(t: Entity): return t.title))
	, self)
	
	super(effect, ability, caster, targets)
	
	assert(!targets.is_empty(), "There are no valid targets!")
	
	for target in targets:
		target.abilities_component.can_act = active
