extends EntityComponent
## An EntityComponent containing Statuses values and logic.
class_name StatusesEntityComponent

## The Dictionary of Effects ongoing on this Entity, paired with how many stacks of the same Effect exist.
## We shouldn't ever have two Effects with the same Resource.
var statuses : Dictionary[Effect, int] = {} 
@export var effect_scene : PackedScene ## A default Effect scene in case we have to construct one.

signal on_status_added(status: Effect) ## Emitted when we add a new status.
signal on_status_removed(status: Effect) ## Emitted when we remove a status.

## Overloaded method for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
## Intializes Stat objects.
func load_entity_resource(resource: EntityResource):
	statuses = {}


## Called every frame. Increments duration for all attached status Effects.
func _process(delta: float) -> void:
	for status in statuses.keys():
		status._duration += delta


## Returns an Effect with a matching EffectResource, if it's present.
func get_effect(effect: Effect) -> Effect:
	for status in statuses:
		if status.shares_resource(effect):
			return status
	return null


## Gets the number of stacks on a given Effect. Returns -1 if there are none.
func get_effect_stacks(effect: Effect) -> int:
	var matching_effect = get_effect(effect)
	if matching_effect:
		return statuses[matching_effect]
	return -1


## Gets the given Effect by its resource, if it's present.
func get_effect_by_resource(effect_resource: EffectResource) -> Effect:
	for status in statuses.keys():
		if effect_resource == status.resource:
			return status
	return null


## Returns an array of Effects matching the given positivity.
func get_effects(status_positivity: Math.Positivity) -> Array[Effect]:
	var effects : Array[Effect] = []
	for effect in statuses:
		if effect._positivity == status_positivity:
			effects.append(effect)
	return effects


## Adds a given Effect with the given stacking behavior.
func add_effect(caster: Entity, effect: Effect, stacking_behavior: EntityAddStatusResource.StackingBehavior):
	var duplicate_effect = get_effect(effect)
	if !duplicate_effect:
		_add_effect(caster, effect)
		return
	match stacking_behavior:
		EntityAddStatusResource.StackingBehavior.Refresh:
			duplicate_effect.reset_lifetime()
		EntityAddStatusResource.StackingBehavior.Ignore:
			return
		EntityAddStatusResource.StackingBehavior.Add:
			statuses[duplicate_effect] += 1
		EntityAddStatusResource.StackingBehavior.AddAndRefresh:
			statuses[duplicate_effect] += 1
			duplicate_effect.reset_lifetime()
		EntityAddStatusResource.StackingBehavior.AddAndReplace:
			var stacks = statuses[duplicate_effect]
			_remove_effect(duplicate_effect)
			_add_effect(caster, effect)
			statuses[effect] = stacks + 1
		EntityAddStatusResource.StackingBehavior.Subtract:
			statuses[duplicate_effect] -= 1
			if statuses[duplicate_effect] <= 0:
				_remove_effect(duplicate_effect)
		EntityAddStatusResource.StackingBehavior.Replace:
			_remove_effect(duplicate_effect)
			_add_effect(caster, effect)


## Does the actual work of adding an Effect.
func _add_effect(caster: Entity, effect: Effect):
	statuses[effect] = 1
	add_child(effect)
	effect.on_lifetime_ended.connect(func(): _remove_effect(effect))
	var targets : Array[Entity] = [entity]
	effect.register(caster, targets)
	on_status_added.emit(effect)


## Does the actual work of removing an Effect.
func _remove_effect(effect: Effect):
	statuses.erase(effect)
	#effect.on_lifetime_ended.disconnect(func(): _remove_effect(effect)) ## Maybe not necessary?
	effect.end()
	on_status_removed.emit(effect)


## Constructs an Effect from the given resource and adds it.
func add_effect_from_resource(caster: Entity, ability: Ability, resource: EffectResource, stacking_behavior: EntityAddStatusResource.StackingBehavior):
	var targets : Array[Entity] = [entity]
	var effect : Effect = effect_scene.instantiate().from_resource(resource, caster, ability, targets)
	add_effect(caster, effect, stacking_behavior)
