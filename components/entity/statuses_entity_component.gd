extends EntityComponent
## An EntityComponent containing Statuses values and logic.
class_name StatusesEntityComponent

var statuses : Array[Effect] = [] ## The Array of Effects ongoing on this Entity.


## Overloaded method for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
## Intializes Stat objects.
func load_entity_resource(resource: EntityResource):
	statuses = []


## Adds a given Effect with the given stacking behavior.
func add_effect(effect: Effect, stacking_behavior: EntityAddStatusResource.StackingBehavior):
	pass


## Adds a given Effect from an EffectResource with the given stacking behavior.
func add_effect_from_resource(effect: EffectResource, stacking_behavior: EntityAddStatusResource.StackingBehavior):
	pass


## Returns whether the Entity has the given Effect currently effective as a status.
func has_status(effect: EffectResource, minimum_stacks: float = 0) -> bool:
	return false
