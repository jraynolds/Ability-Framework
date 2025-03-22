extends Resource
## A Resource representing a trigger. Not meant to be mutated in runtime.
class_name TriggerResource

@export var title : String ## The title of this Trigger.
@export_multiline var description : String ## The description for this Trigger.
enum Trigger {
	OnThisAbilityCast = 0, ## When the associated Ability is cast
}
## The type of Trigger. By default, when the associated Ability is cast.
@export var trigger : Trigger = Trigger.OnThisAbilityCast 


## Adds a listener to the appropriate game trigger for the given Effect.
func register(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity], function: Variant):
	match trigger :
		Trigger.OnThisAbilityCast:
			print("Registered")
			ability.on_cast.connect(function.bind(caster, targets))


## Removes a listener from the appropriate game trigger for the given Effect.
func unregister(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity], function: Variant):
	match trigger :
		Trigger.OnThisAbilityCast:
			ability.on_cast.disconnect(function.bind(caster, targets))
