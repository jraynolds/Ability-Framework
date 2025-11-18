extends Node
## The runtime instance of an AbilityResource.
class_name Ability

## The base AbilityResource this Ability represents. Changing it creates instance copies of many of its fields.
var _resource : AbilityResource : 
	set(val):
		_resource = val
		_title = _resource.title
		_icon = _resource.icon
		_targeting_resource = _resource.targeting
		for effect_resource in _resource.effects:
			var targets : Array[Entity] = []
			var effect : Effect = effect_scene.instantiate().from_resource(effect_resource, self,  _caster, targets)
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
		for conditional in _resource.conditionals_highlight:
			_conditionals_highlight.append(conditional)
var _title : String ## The title of the Ability.
var _icon : Texture2D ## The icon for this Ability.
var _targeting_resource : TargetingResource ## The Resource that will find the target(s) for this Ability to affect.
var _effects : Array[Effect] = [] ## An Array of Effects this Ability will perform.
var casting : bool ## Whether or not the Ability is currently being cast by its caster.
var _casting_time : ValueResource ## The duration in seconds this Ability takes to cast.
var _cast_time_left : float ## The duration in seconds remaining before this Ability is fully cast.
var _cooldown : ValueResource ## The duration in seconds before this Ability can be cast again.
var _cooldown_left : float ## The remaining duration before this Ability can be cast again.
## This Ability's interaction with the Global Cooldown.
## GCDs put all GCD Abilities on a shared cooldown; oGCDs don't.
var _gcd_type : AbilityResource.GCD
## The duration in seconds this Ability will put all GCDs into cooldown. Ignored if the Ability is OffGCD.
var _gcd_cooldown : ValueResource
## The conditionals that allow this Ability to be cast.
var _conditionals_positive : Array[ConditionalResource] = [] 
## The conditionals restricting this Ability from being cast.
var _conditionals_negative : Array[ConditionalResource] = [] 
## The conditionals that highlight the Ability on the hotbar.
var _conditionals_highlight : Array[ConditionalResource] = []

var _caster : Entity ## The Entity who owns this Ability.
var _targets : Array[Entity] ## The Entities who this Ability is targeting.

@export var effect_scene : PackedScene ## The default Effect scene.

signal on_cast_begin(caster: Entity, targets: Array[Entity]) ## emitted when this Ability begins to cast.
signal on_cast(caster: Entity, targets: Array[Entity]) ## emitted when this Ability is successfully cast.

## Called every frame. Reduces the cooldown left.
func _process(delta: float) -> void:
	if casting and _cast_time_left >= 0.0:
		_cast_time_left -= delta
		if _cast_time_left <= 0.0:
			cast()
	if _cooldown_left > 0.0:
		_cooldown_left -= delta


## Returns an instance of this initialized with the given AbilityResource and Entity.
func from_resource(resource: AbilityResource, caster: Entity) -> Ability:
	_resource = resource
	_caster = caster
	return self


## Begins to cast this ability.
func begin_cast(targets: Array[Entity]):
	DebugManager.debug_log(
		"Ability " + _title + " is beginning to be cast by " + _caster.title + 
		" at targets " + ",".join(targets.map(func(t: Entity): return t.title))
	, self)
	_targets = targets
	on_cast_begin.emit(_caster, _targets)
	_cast_time_left = get_casting_time()
	for effect in _effects:
		effect.register(_caster, _targets)
	casting = true


## Performs this ability on the given targets, from our owner.
func cast():
	_cooldown_left = get_cooldown()
	on_cast.emit(_caster, _targets)
	DebugManager.debug_log(
		"Ability " + _title + " has successfully been cast by " + _caster.title + 
		" at targets " + ",".join(_targets.map(func(t: Entity): return t.title))
	, self)
	casting = false


## Returns whether this Ability's resource is equal to the given AbilityResource.
func is_resource_equal(resource: AbilityResource):
	return resource == _resource


## Returns whether this Ability can be cast. Finds the default targets.
func is_castable() -> bool:
	var targets = _targeting_resource.get_targets(_caster, self) if _targeting_resource else _caster.targeting_component.targets
	return is_castable_at(targets)


## Returns whether this Ability can be cast at the given targets.
func is_castable_at(targets: Array[Entity]) -> bool:
	for conditional in _conditionals_positive:
		if !conditional.is_met(null, self, _caster, targets):
			return false
	for conditional in _conditionals_negative:
		if conditional.is_met(null, self, _caster, targets):
			return false
	return true


## Returns whether this Ability is highlit.
func _is_highlighted(targets: Array[Entity]) -> bool:
	if _conditionals_highlight.is_empty():
		return false
	for conditional in _conditionals_highlight:
		if !conditional.is_met(null, self, _caster, targets):
			return false
	return true


## Returns the default targets this Ability gets.
func get_targets() -> Array[Entity]:
	var targets =  _caster.targeting_component.targets
	if _targeting_resource:
		targets = _targeting_resource.get_targets(_caster, self)
	return targets


## Returns the cooldown of this Ability. By default, 0.
func get_cooldown() -> float:
	if !_cooldown:
		return 0.0
	return _cooldown.get_value(_caster, _targets)


## Returns the cast time of this Ability. By default, 0.
func get_casting_time() -> float:
	if !_casting_time:
		return 0.0
	return _casting_time.get_value(_caster, _targets)


## Cancels the current casting of this ability.
func cancel_cast():
	casting = false
	for effect in _effects:
		effect.cancel()
