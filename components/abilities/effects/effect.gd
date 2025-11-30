extends Node
class_name Effect
## The runtime instance of an EffectResource.

var _resource : EffectResource ## The base EffectResource this Effect represents.
var _title : String ## The title of this Effect.
var _description : String ## The description of this Effect.
var _positivity : Math.Positivity ## Whether this Effect is good, bad, or neither for its target.
var _icon : Texture2D ## The icon for this Effect.
var _triggers : Array[TriggerResource] = [] ## The triggers that cause this Effect.
var _conditionals_positive : Array[ConditionalResource] = [] ## The conditionals that allow this Effect.
var _conditionals_negative : Array[ConditionalResource] = [] ## The conditionals that disallow this Effect.

var _caster : Entity ## The Entity responsible for the creation of this Effect.
var _ability : Ability ## The Ability that created this Effect.
var _targets : Array[Entity] ## The Entities targeted by this Effect.

var _sub_effects : Array[Effect] = [] ## Sub-effects this Effect also tracks.

var _temp_effects : Array[Effect] = [] ## Temporary effects this Effect has created.
var _active_temp_effects : Array[Effect] : ## Those of our _temp_effects which are currently active.
	get :
		return _temp_effects.filter(func(temp_effect): return temp_effect != null)
#var canceled : bool  ## Whether this effect has been canceled.

 ## A Dictionary storing information about how times, and by what TriggerResources, this Effect has affected its targets.
var times_triggered : Dictionary[TriggerResource, int]
var total_times_triggered : int : ## The total times this Effect has affected its targets. 
	get :
		var out = 0
		for time : TriggerResource in times_triggered.keys():
			out += times_triggered[time]
		return out
## A Dictionary storing information about how many seconds have occurred since the last time this Effect was triggered.
## Tracks each TriggerResource source individually. 
var time_since_last_trigger : Dictionary[TriggerResource, float]
#signal on_times_triggered_changed(new_vlaue: float, old_value: float) ## Emitted when the number of times triggered changes.

signal on_registered ## Emitted when this Effect is fully registered on all its Triggers.
#signal on_affected(caster: Entity, targets: Array[Entity]) ## Emitted when this Effect affects its targets.
#signal on_unregistered ## Emitted when this Effect is fully unregistered on all its Triggers.
signal on_expired ## Emitted when this Effect expires.

## Returns an instance of this initialized with the given EffectResource.
func from_resource(res: EffectResource, ability: Ability, caster: Entity, targets: Array[Entity]) -> Effect:
	update_resource(res)
	_caster = caster
	_ability = ability
	_targets = targets
	name = _title
	_resource.on_created(self, ability, caster, targets)
	
	return self


## Returns an instance of this initialized with the given Effect.
func from_effect(effect: Effect) -> Effect:
	_resource = effect._resource
	_title = effect._title
	_description = effect._description
	_positivity = effect._positivity
	_icon = effect._icon
	for trigger in effect._triggers:
		_triggers.append(trigger)
	for conditional in effect._conditionals_positive:
		_conditionals_positive.append(conditional)
	for conditional in effect._conditionals_negative:
		_conditionals_negative.append(conditional)
	_caster = effect._caster
	_ability = effect._ability
	_targets = effect._targets
	name = _title
	_resource.on_created(self, _ability, _caster, _targets)
	
	return self


## Updates this Effect's Resource with another.
func update_resource(res: EffectResource):
	_resource = res
	_title = _resource.title
	_description = _resource.description
	_positivity = _resource.positivity
	_icon = _resource.icon
	for trigger in _resource.triggers:
		_triggers.append(trigger)
		times_triggered[trigger] = 0
	for conditional in _resource.conditionals_positive:
		_conditionals_positive.append(conditional)
	for conditional in _resource.conditionals_negative:
		_conditionals_negative.append(conditional)


## Called every time the battle advances an active frame. Increments the time we've been waiting for our triggers.
func on_battle_tick(delta: float):
	for sub_effect in _sub_effects:
		sub_effect.on_battle_tick(delta)
	for temp_effect in _temp_effects:
		temp_effect.on_battle_tick(delta)
	for trigger in time_since_last_trigger.keys():
		time_since_last_trigger[trigger] += delta


## If usable, makes a copy and registers this effect on the appropriate triggers.
func register(caster: Entity, targets: Array[Entity]):
	DebugManager.debug_log(
		"Attempting to register effect " + _title
	, self)
	
	for conditional in _conditionals_positive:
		if !conditional.is_met(self, _ability, caster, targets):
			DebugManager.debug_log(
				"Couldn't register effect " + _title + 
				" because it didn't meet conditional " + conditional.resource_name
			, self)
			return
	for conditional in _conditionals_negative:
		if conditional.is_met(self, _ability, caster, targets):
			DebugManager.debug_log(
				"Couldn't register effect " + _title + 
				" because it met conditional " + conditional.resource_name
			, self)
			return
	
	DebugManager.debug_log(
		"Registering effect " + _title
	, self)
	
	_caster = caster
	_targets = targets
	
	var effect_temp : Effect = self.duplicate(10).from_effect(self) ## Duplicates with values
	effect_temp.name = _title + " targeting " + ", ".join(targets.map(func(t: Entity): return t.title))
	_temp_effects.append(effect_temp)
	add_child(effect_temp, true)
	
	for trigger in _triggers:
		trigger.register(self, _ability, caster, targets, effect_temp.affect_if_trigger_ready)
	on_registered.emit()
	
	DebugManager.debug_log(
		"Registered effect " + _title
	, self)


## Performs this Effect on the given targets, from the given caster, from the given trigger.
## Only works if we've exceeded the cooldown for the given trigger.
func affect_if_trigger_ready(caster: Entity, targets: Array[Entity], trigger: TriggerResource):
	DebugManager.debug_log(
		"Attempting to affect targets with effect " + _title + " from the trigger " + trigger.resource_path +
		", if its cooldown is ready"
	, self)
	
	if trigger.cooldown:
		if trigger in time_since_last_trigger:
			DebugManager.debug_log(
				"Time since last trigger is " + str(time_since_last_trigger[trigger])
			, self)
			if time_since_last_trigger[trigger] < trigger.cooldown.get_value(caster, targets):
				DebugManager.debug_log(
					"Failed to affect with " + _title + " from the trigger " + trigger.resource_path +
					", because its cooldown wasn't ready"
				, self)
				return
		else :
			DebugManager.debug_log(
				"It's the first time we've been triggered, so we have no cooldown"
			, self)
			time_since_last_trigger[trigger] = 0.0
	
	affect(caster, targets, trigger)


## Performs this Effect on the given targets, from the given caster, from the given trigger.
func affect(caster: Entity, targets: Array[Entity], trigger: TriggerResource):
	DebugManager.debug_log(
		"Affecting targets with effect " + _title + " from the trigger " + trigger.resource_path
	, self)
	
	if trigger in times_triggered:
		times_triggered[trigger] += 1
	else :
		times_triggered[trigger] = 1
	time_since_last_trigger[trigger] = 0.0
	
	for target in targets:
		DebugManager.debug_log(
			"Affecting target " + target._resource.title + " with effect " + _title + 
			" from the trigger " + trigger.resource_path
		, self)
		_resource.on_affect(self, _ability, caster, targets)
	
	#end() ## By default, we have no duration--so we should just get rid of ourselves


## Adds a sub-Effect to our array and adds it as a child.
func add_sub_effect(sub_effect: Effect):
	_sub_effects.append(sub_effect)
	add_child(sub_effect)


## Removes all active sub effects.
func clear_sub_effects():
	for i in range(len(_sub_effects)):
		_sub_effects[i].end()
		_sub_effects.remove_at(i)


## Removes all active temp effects.
func clear_temp_effects():
	for i in range(len(_temp_effects)):
		_temp_effects[i].end()
		_temp_effects.remove_at(i)


## Returns whether the given Effect shares our same EffectResource.
func shares_resource(effect: Effect) -> bool:
	return effect._resource == _resource


## Returns whether the given EffectResource is the same as ours.
func has_resource(resource: EffectResource) -> bool:
	return _resource == resource


## Ends this Effect.
func end():
	DebugManager.debug_log(
		"Effect " + _title + " is expiring"
	, self)
	
	on_expired.emit()
	queue_free()


## Cancels this effect, removing all Effect children.
func cancel():
	for temp_effect in _active_temp_effects:
		temp_effect.end()
