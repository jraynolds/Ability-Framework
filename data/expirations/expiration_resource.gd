extends Resource
## Resource for a conditional expiration on a StatusEffect.
class_name ExpirationResource

@export var stacks_removed : ValueResource ## The amount of stacks removed from the StatusEffect. By default, all.

## Registers a listener to expire the Effect.
func register(status: StatusEffect, ability: Ability, caster: Entity, targets: Array[Entity]):
	pass


## Causes the selected expiration behavior to happen for the StatusEffect.
func expire_effect(
	status: StatusEffect, 
	ability: Ability = status._ability, 
	caster: Entity = ability._caster,
	targets: Array[Entity] = []
):
	if stacks_removed:
		for target in status._targets:
			target.statuses_component.modify_stacks(status, -stacks_removed.get_value(caster, targets))
	else :
		for target in status._targets:
			target.statuses_component.remove_status(status)
