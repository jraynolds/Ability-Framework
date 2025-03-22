extends Node
## A base-level component attached to an Entity.
class_name EntityComponent

## The Entity this EntityComponent is attached to. Changing this runs an initialization method.
@export var entity : Entity :
	set(val):
		entity = val
		on_entity_updated()

## Overloaded method for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
func load_entity_resource(resource: EntityResource):
	pass


## Overloaded method for logic that happens when the Entity value is updated.
func on_entity_updated():
	pass
