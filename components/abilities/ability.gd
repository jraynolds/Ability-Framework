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
		_max_channel_time = _resource.max_channel_time
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
var _casting_time : ValueResource ## The duration in seconds this Ability takes to cast.
var _cast_time_left : float ## The duration in seconds remaining before this Ability is fully cast.
var _cooldown : ValueResource ## The duration in seconds before this Ability can be cast again.
var _cooldown_left : float ## The remaining duration before this Ability can be cast again.
## The maximum duration in seconds (if any) this Ability can be "held," producing its effects repeatedly.
var _max_channel_time : ValueResource
var _channel_time_left : float ## How many seconds remain in this Ability's channel.
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

var casting_time : float : ## The duration in seconds this Ability takes to cast. By default, 0 seconds.
	get: return _casting_time.get_value(_caster, _targets) if _casting_time else 0.0
var cooldown : float : ## The duration in seconds before this Ability can be cast again. By default, 0 seconds.
	get: return _cooldown.get_value(_caster, _targets) if _cooldown else 0.0
var casting : bool : ## Whether or not the Ability is currently being cast by its caster. Changing this emits signals.
	set(val):
		var old_val = casting
		casting = val
		if val and !old_val:
			on_cast_begin.emit(_caster, _targets)
		if !val and old_val:
			on_cast.emit(_caster, _targets)
var channeling : bool : ## Whether or not the Ability is currently being channeled by its caster. Changing this emits signals.
	set(val):
		var old_val = channeling
		channeling = val
		if val and !old_val:
			_channel_time_left = max_channel_time
			on_channel_begin.emit(_caster, _targets)
		if !val and old_val:
			on_channel_ended.emit(_caster, _targets)
## The maximum duration in seconds (if any) this Ability can be "held," producing its effects repeatedly. By default, 0 seconds.
var max_channel_time : float :
	get: return _max_channel_time.get_value(_caster, _targets) if _max_channel_time else 0.0
var active : bool : ## Whether this Ability is being cast or channeled.
	get :
		return casting or channeling
	#set(val):
		#var old_val = active
		#active = val
		#if val and !old_val:
			#on_cast_begin.emit(_caster, _targets)
		#if !val and old_val:
			#on_cast.emit(_caster, _targets)

@export var effect_scene : PackedScene ## The default Effect scene.

## Emitted when this Ability becomes active, usually by being cast.
#signal on_become_active(caster: Entity, targets: Array[Entity]) 
## Emitted when this Ability becomes inactive, usually by the cast or channel finishing.
#signal on_become_inactive(caster: Entity, targets: Array[Entity])

signal on_cast_begin(caster: Entity, targets: Array[Entity]) ## Emitted when this Ability begins to cast.
#signal on_cast_failed(caster: Entity, targets: Array[Entity]) ## Emitted when this Ability is interrupted or canceled.
signal on_cast(caster: Entity, targets: Array[Entity]) ## Emitted when this Ability is successfully cast.
signal on_channel_begin(caster: Entity, targets: Array[Entity]) ## Emitted when this Ability begins to channel after a successful cast.
signal on_channel_tick(caster: Entity, targets: Array[Entity], tick_time: float) ## Emitted every frame this Ability channels.
#signal on_channel_failed(caster: Entity, targets: Array[Entity]) ## Emitted when this Ability's channeling is interrupted or canceled.
signal on_channel_ended(caster: Entity, targets: Array[Entity]) ## Emitted when this Ability's channeling ends.

## Called every frame. Reduces the cooldown left.
func on_battle_tick(delta: float) -> void:
	for effect in _effects:
		effect.on_battle_tick(delta)
	
	if casting and _cast_time_left >= 0.0:
		_cast_time_left -= delta
		if _cast_time_left <= 0.0:
			cast()
	if channeling and _channel_time_left >= 0.0:
		_channel_time_left -= delta
		if _channel_time_left <= 0.0:
			on_channel_ended.emit(_caster, _targets)
		else :
			on_channel_tick.emit(_caster, _targets, delta)
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
	_cast_time_left = casting_time
	for effect in _effects:
		effect.register(_caster, _targets)
	casting = true
	active = true


## Performs this ability on the given targets, from our owner.
func cast():
	casting = false
	DebugManager.debug_log(
		"Ability " + _title + " has successfully been cast by " + _caster.title + 
		" at targets " + ",".join(_targets.map(func(t: Entity): return t.title))
	, self)
	_cooldown_left = cooldown


## Performs this ability's channel on the given targets, from our owner.
func channel():
	channeling = true
	DebugManager.debug_log(
		"Ability " + _title + " is beginning to be channeled by " + _caster.title + 
		" at targets " + ",".join(_targets.map(func(t: Entity): return t.title))
	, self)


## Performs the cleanup at the end of the Ability's lifetime.
func end():
	DebugManager.debug_log(
		"Ability " + _title + " is performing cleanup"
	, self)
	channeling = false
	active = false
	for effect in _effects:
		effect.clear_temp_effects()


## Returns whether this Ability's resource is equal to the given AbilityResource.
func is_resource_equal(resource: AbilityResource):
	return resource == _resource


## Returns whether this Ability can be cast. Finds the default targets.
func is_castable() -> bool:
	var targets = _targeting_resource.get_targets(_caster, self) if _targeting_resource else _caster.targeting_component.targets
	return is_castable_at(targets)


## Returns whether this Ability can be cast at the given targets.
func is_castable_at(targets: Array[Entity]) -> bool:
	for target in targets:
		if !target.targeting_component.is_targetable():
			return false
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


## Cancels the current casting of this ability.
func cancel_cast():
	casting = false
	for effect in _effects:
		effect.cancel()
