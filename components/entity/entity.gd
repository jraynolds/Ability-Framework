extends Node
## The runtime instance of an EntityResource.
class_name Entity

@export var _resource : EntityResource ## The base Entity this instance represents.
## Get/Setter for the EntityResource. Setting this initializes the Entity.
var resource : EntityResource :
	get :
		return _resource
	set(val):
		_resource = val
		title = _resource.title
		icon = _resource.icon
		description = _resource.description
		name = _resource.title
		stats_component.load_entity_resource(_resource)
		statuses_component.load_entity_resource(_resource)
		abilities_component.load_entity_resource(_resource)

@export var stats_component : StatsEntityComponent ## The Stats component for this Entity.
@export var statuses_component : StatusesEntityComponent ## The Statuses component for this Entity.
@export var abilities_component : AbilitiesEntityComponent ## The Abilities component for this Entity.
@export var history_component : HistoryEntityComponent ## The history component for this Entity.

var title : String ## The name of the Entity.
var icon : Texture2D ## The icon for this Entity.
var description : String ## The description of this Entity.
