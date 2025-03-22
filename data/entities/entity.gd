extends Node
## The runtime instance of an EntityResource.
class_name Entity

@export var resource : EntityResource ## The base Entity this instance represents.

@export var stats_component : StatsEntityComponent ## The Stats component for this Entity.
@export var statuses_component : StatusesEntityComponent ## The Statuses component for this Entity.
@export var abilities_component : AbilitiesEntityComponent ## The Abilities component for this Entity.
