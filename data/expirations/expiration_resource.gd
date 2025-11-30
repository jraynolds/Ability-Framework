extends Resource
## Resource for a conditional expiration on a LifetimeEffect.
class_name ExpirationResource

@export var triggers : Array[TriggerResource] ## The triggers that cause this expiration
@export var stacks_removed : ValueResource ## The amount of stacks removed from the LifetimeEffect. By default, all.

## Registers a listener to expire the Effect.
func register(lifetime: LifetimeEffect, ability: Ability, caster: Entity, targets: Array[Entity]):
	DebugManager.debug_log(
		"LifetimeEffect " + lifetime._title + "'s expiration effects are being registered to its triggers"
	, self)
	for trigger in triggers:
		trigger.register(lifetime, ability, caster, targets, lifetime.expire_from_resource.bind(self))
		DebugManager.debug_log(
			"LifetimeEffect " + lifetime._title + "'s expiration effects has been registered to trigger " + 
			trigger.title
		, self)


## Causes the selected expiration behavior to happen for the LifetimeEffect.
func expire_effect(
	lifetime: LifetimeEffect, 
	ability: Ability = lifetime._ability, 
	caster: Entity = ability._caster, 
	targets: Array[Entity] = []
):
	DebugManager.debug_log(
		"LifetimeEffect " + lifetime._title + "'s expiration effect is being triggered"
	, self)
	if stacks_removed:
		for target in lifetime._targets:
			target.statuses_component.modify_stacks(lifetime, -stacks_removed.get_value_int(caster, targets))
	else :
		lifetime.end()
