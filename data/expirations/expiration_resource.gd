extends Resource
## Resource for a conditional expiration on a StatusEffect.
class_name ExpirationResource

@export var triggers : Array[TriggerResource] ## The triggers that cause this expiration
@export var stacks_removed : ValueResource ## The amount of stacks removed from the StatusEffect. By default, all.

## Registers a listener to expire the Effect.
func register(status: StatusEffect, ability: Ability, caster: Entity, targets: Array[Entity]):
	DebugManager.debug_log(
		"StatusEffect " + status._title + "'s expiration effects are being registered to its triggers"
	, self)
	for trigger in triggers:
		DebugManager.debug_log(
			"StatusEffect " + status._title + "'s expiration effects are being registered to trigger " + 
			trigger.title
		, self)
		trigger.register(ability, caster, targets, status.expire_from_resource.bind(self))


## Causes the selected expiration behavior to happen for the StatusEffect.
func expire_effect(status: StatusEffect, ability: Ability = status._ability, caster: Entity = ability._caster, targets: Array[Entity] = []):
	DebugManager.debug_log(
		"StatusEffect " + status._title + "'s expiration effect is being triggered"
	, self)
	if stacks_removed:
		for target in status._targets:
			target.statuses_component.modify_stacks(status, -stacks_removed.get_value_int(caster, targets))
	else :
		status.end()
