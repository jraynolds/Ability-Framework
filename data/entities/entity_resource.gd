extends Resource
## A Resource representing an Entity. Not meant to be mutated in runtime.
class_name EntityResource

@export var title : String ## The name of this Entity.
@export var icon : Texture2D ## The icon of this Entity.
@export_multiline var description : String ## The description of this Entity.
## The Stats this entity has, and what its starting values are.
@export var stats : Dictionary[StatResource, ValueResource]
## The Abilities this Entity starts with, paired with the default bar locations for each Ability. 
## The integer can be 0-19; 0 is "1", 10 is "+1"
@export var abilities : Dictionary[AbilityResource, int]
