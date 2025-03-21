extends Node
## The runtime instance of an AbilityResource.
class_name Ability

var _resource : AbilityResource ## The base AbilityResource this Ability represents.
var _title : String ## The title of the Ability.
var _icon : Texture2D ## The icon for this Ability.
var _effects : Array[Effect] = [] ## An Array of Effects this Ability will perform.
var _casting_time : ValueResource ## The duration in seconds this Ability takes to cast.
var _cast_time_left : float ## The duration in seconds remaining before this Ability is fully cast.
var _cooldown : ValueResource ## The duration in seconds before this Ability can be cast again.
## This Ability's interaction with the Global Cooldown. GCDs put all GCD Abilities on a shared cooldown; oGCDs don't.
var _gcd_type : AbilityResource.GCD
## The duration in seconds this Ability will put all GCDs into cooldown. Ignored if the Ability is OffGCD.
var _gcd_cooldown : ValueResource
var _conditionals_positive : Array[ConditionalResource] = [] ## The conditionals that allow this Ability to be cast.
var _conditionals_negative : Array[ConditionalResource] = [] ## The conditionals restricting this Ability from being cast.

signal on_cast_begin ## emitted when this Ability begins to cast.
signal on_cast ## emitted when this Ability is successfully cast.

## Returns an instance of this initialized with the given AbilityResource.
func from_resource(resource: AbilityResource) -> Ability:
	_resource = resource
	_title = resource.title
	_icon = resource.icon
	for effect in resource.effects:
		_effects.append(Effect.new().from_resource(effect))
	_casting_time = resource.casting_time
	_cooldown = resource.cooldown
	_gcd_type = resource.gcd_type
	_gcd_cooldown = resource.gcd_cooldown
	for conditional in resource.conditionals_positive:
		_conditionals_positive.append(conditional)
	for conditional in resource.conditionals_negative:
		_conditionals_negative.append(conditional)
	return self


## Begins to cast this ability.
func begin_cast(caster: Entity, targets: Array[Entity]):
	on_cast_begin.emit()
	_cast_time_left = _casting_time.get_value(caster, targets)


## Performs this ability on the given targets, from the given caster.
func cast(caster: Entity, targets: Array[Entity]):
	for effect in _effects:
		effect.register(self, caster, targets)
	on_cast.emit()


## Returns whether this Ability's resource is equal to the given AbilityResource.
func is_resource_equal(resource: AbilityResource):
	return resource == _resource


## Returns whether this Ability can be cast.
func _is_castable(caster: Entity, targets: Array[Entity]):
	for conditional in _conditionals_positive:
		if !conditional.is_met(null, self, caster, targets):
			return false
	for conditional in _conditionals_negative:
		if conditional.is_met(null, self, caster, targets):
			return false
	return true
