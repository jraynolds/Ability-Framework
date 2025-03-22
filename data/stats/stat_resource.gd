extends Resource
## A Resource representing a character statistic. Not meant to be mutated in runtime.
class_name StatResource

@export var title : String ## The title of this Stat.
@export var type : StatType ## The type of this Stat.
@export_multiline var description : String ## The description for this Stat's purpose.
@export var is_int : bool ## Whether this Stat is an integer.
## If this Value should output an integer, the rounding method it should use.
@export var rounding_behavior : Math.Rounding = Math.Rounding.Floor
@export var max : float = 9999 ## The maximum allowed value of this Stat.
@export var min : float = -9999 ## The minimum allowed value of this Stat.

enum StatType {
	HP = 0,
	MaxHP = 1,
	Mana = 10,
	MaxMana = 11,
	Attack = 20,
	Defense = 30,
	AbilitySpeed = 40,
	GCDCooldown = 41,
}
