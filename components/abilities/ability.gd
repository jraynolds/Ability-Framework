extends Node
## The runtime instance of an AbilityResource.
class_name Ability

## The base AbilityResource this Ability represents. Changing it creates instance copies of many of its fields.
var _resource : AbilityResource : 
	set(val):
		_resource = val
		_title = _resource.title
		_icon = _resource.icon
		for effect_resource in _resource.effects:
			var effect : Effect = effect_scene.instantiate().from_resource(effect_resource)
			_effects.append(effect)
			add_child(effect)
			effect.name = effect._title
		_casting_time = _resource.casting_time
		_cooldown = _resource.cooldown
		_gcd_type = _resource.gcd_type
		_gcd_cooldown = _resource.gcd_cooldown
		for conditional in _resource.conditionals_positive:
			_conditionals_positive.append(conditional)
		for conditional in _resource.conditionals_negative:
			_conditionals_negative.append(conditional)
var _title : String ## The title of the Ability.
var _icon : Texture2D ## The icon for this Ability.
var _effects : Array[Effect] = [] ## An Array of Effects this Ability will perform.
var _casting_time : ValueResource ## The duration in seconds this Ability takes to cast.
var _cast_time_left : float ## The duration in seconds remaining before this Ability is fully cast.
var _cooldown : ValueResource ## The duration in seconds before this Ability can be cast again.
## This Ability's interaction with the Global Cooldown.
## GCDs put all GCD Abilities on a shared cooldown; oGCDs don't.
var _gcd_type : AbilityResource.GCD
## The duration in seconds this Ability will put all GCDs into cooldown. Ignored if the Ability is OffGCD.
var _gcd_cooldown : ValueResource
## The conditionals that allow this Ability to be cast.
var _conditionals_positive : Array[ConditionalResource] = [] 
## The conditionals restricting this Ability from being cast.
var _conditionals_negative : Array[ConditionalResource] = [] 

@export var effect_scene : PackedScene ## The default Effect scene.

signal on_cast_begin ## emitted when this Ability begins to cast.
signal on_cast ## emitted when this Ability is successfully cast.

## Returns an instance of this initialized with the given AbilityResource.
func from_resource(resource: AbilityResource) -> Ability:
	_resource = resource
	return self


## Begins to cast this ability.
func begin_cast(caster: Entity, targets: Array[Entity]):
	on_cast_begin.emit()
	_cast_time_left = _casting_time.get_value(caster, targets)


## Performs this ability on the given targets, from the given caster.
func cast(caster: Entity, targets: Array[Entity]):
	for effect in _effects:
		effect.register(self, caster, targets)
	print("Cast")
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
