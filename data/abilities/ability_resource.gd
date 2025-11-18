extends Resource
class_name AbilityResource
## A Resource representing an ability. Not meant to be mutated in runtime.

@export var title : String ## The title of the Ability.
@export var icon : Texture2D ## The icon for this Ability.
@export_multiline var description : String ## The description for this Ability.
@export var targeting : TargetingResource ## The method by which this Ability finds its targets.
@export var cancelable : bool = true ## Whether this Ability can be canceled by the caster.
@export var interruptible : bool = true ## Whether this Ability can be canceled by others.
@export var effects : Array[EffectResource] ## An Array of EffectResources this Ability will perform.
@export var casting_time : ValueResource ## The duration in seconds this Ability takes to cast.
@export var cooldown : ValueResource ## The duration in seconds before this Ability can be cast again.
@export var gcd_type : GCD = GCD.OnGCD ## This Ability's interaction with the Global Cooldown.
enum GCD {
	OnGCD, ## GCDs put all GCD Abilities on a shared cooldown.
	OffGCD ## GCDs don't put any other Ability on a cooldown.
}
## The duration in seconds this Ability will put all GCDs into cooldown. Ignored if the Ability is OffGCD.
@export var gcd_cooldown : ValueResource
## The conditionals that allow this Ability to be cast.
@export var conditionals_positive : Array[ConditionalResource]
## The conditionals restricting this Ability from being cast.
@export var conditionals_negative : Array[ConditionalResource]
## The conditionals that highlight the Ability on the hotbar.
@export var conditionals_highlight : Array[ConditionalResource]
