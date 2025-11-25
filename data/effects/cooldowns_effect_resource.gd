extends EffectResource
## Modifies the target's cooldowns.
class_name CooldownsEffectResource

@export var cooldown_amount : ValueResource ## How much we should modify the target's cooldowns by.
@export var math_operation : Math.Operation ## The type of mathematics operation we'll perform.

## Called when an Effect containing this Resource is created. Meant to be overloaded.
func on_created(_effect: Effect, _ability: Ability, _caster: Entity, _targets: Array[Entity]):
	pass


## Called when an Effect containing this Resource affects targets. Meant to be overloaded.
func on_affect(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	super(effect, ability, caster, targets)
	
	if targeting_override:
		targets = targeting_override.get_targets(caster, ability)
	
	var cooldown_modification = cooldown_amount.get_value(caster, targets)
	
	for target in targets:
		target.abilities_component.modify_cooldowns(cooldown_modification, math_operation)
