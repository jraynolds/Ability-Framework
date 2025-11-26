extends Node
## A base-level component attached to an Entity.
class_name EntityComponent

## The Entity this EntityComponent is attached to. Changing this runs an initialization method.
@export var entity : Entity :
	set(val):
		entity = val
		on_entity_updated()

## Overloadable function for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
func load_entity_resource(_resource: EntityResource):
	pass


## Overloadable function for logic that happens when the Entity value is updated.
func on_entity_updated():
	pass


## Overloadable function for logic that happens every time the battle advances a frame.
func on_battle_tick(_delta: float):
	pass
