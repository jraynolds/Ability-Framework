extends EntityComponent
## An EntityComponent containing Statuses values and logic.
class_name StatusesEntityComponent

## The Array of Effects ongoing on this Entity, ordered by when they were added.
var statuses : Array[StatusEffect]
## The Dictionary of Effects ongoing on this Entity, paired with how many stacks of the same Effect exist.
var status_stacks : Dictionary[StatusEffect, int] = {} 
@export var initial_statuses : Array[StatusAddEffectResource] ## Statuses the Entity begins with can be added here.
@export var status_effect_scene : PackedScene ## A default StatusEffect scene in case we have to construct one.

signal on_status_added(status: StatusEffect) ## Emitted when we add a new status.
signal on_status_removed(status: StatusEffect) ## Emitted when we remove a status.

## Overloaded method for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
## Initializes any initial statuses.
func load_entity_resource(resource: EntityResource):
	statuses = []
	status_stacks = {}
	for status in initial_statuses:
		var status_effect = status_effect_scene.instantiate().from_resource(
			status.effect_added,
			null,
			entity,
			[entity]
		).with_status(
			status.lifetimes,
			status.expiration_behavior
		)
		add_status(status_effect, null, null, entity, status.stacking_behavior)


## Called every frame. Increments duration for all attached status Effects.
func _process(delta: float) -> void:
	for status in statuses:
		status._duration += delta


## Returns a StatusEffect with a matching EffectResource, if it's present.
func get_status(effect: Effect) -> StatusEffect:
	for status in statuses:
		if status.shares_resource(effect):
			return status
	return null


## Gets the number of stacks on a given StatusEffect. Returns -1 if there are none.
func get_status_stacks(effect: Effect) -> int:
	var matching_status = get_status(effect)
	if matching_status:
		return status_stacks[matching_status]
	return -1


## Gets the given StatusEffect by its resource, if it's present.
func get_status_by_resource(effect_resource: EffectResource) -> Effect:
	for status in statuses:
		if effect_resource == status.resource:
			return status
	return null


## Returns an array of StatusEffects matching the given positivity.
func get_statuses(status_positivity: Math.Positivity) -> Array[Effect]:
	var matching_statuses : Array[Effect] = []
	for status in statuses:
		if status._positivity == status_positivity:
			matching_statuses.append(status)
	return matching_statuses


## Adds a given StatusEffect with the given stacking behavior.
func add_status(
	effect: Effect,
	adding_effect: Effect,
	adding_ability: Ability,
	caster: Entity,
	stacking_behavior: StatusAddEffectResource.StackingBehavior,
	num_stacks: int = 1
):
	var duplicate_effect = get_status(effect)
	if !duplicate_effect:
		_add_status(effect, caster)
		return
	match stacking_behavior:
		StatusAddEffectResource.StackingBehavior.Refresh:
			duplicate_effect.reset_lifetime()
		StatusAddEffectResource.StackingBehavior.Ignore:
			return
		StatusAddEffectResource.StackingBehavior.Add:
			status_stacks[duplicate_effect] += num_stacks
		StatusAddEffectResource.StackingBehavior.AddAndRefresh:
			status_stacks[duplicate_effect] += num_stacks
			duplicate_effect.reset_lifetime()
		StatusAddEffectResource.StackingBehavior.AddAndReplace:
			var stacks = statuses[duplicate_effect]
			_remove_status(duplicate_effect)
			_add_status(effect, caster)
			statuses[effect] = stacks + num_stacks
		StatusAddEffectResource.StackingBehavior.Subtract:
			status_stacks[duplicate_effect] -= num_stacks
			if status_stacks[duplicate_effect] <= 0:
				_remove_status(duplicate_effect)
		StatusAddEffectResource.StackingBehavior.Replace:
			_remove_status(duplicate_effect)
			_add_status(effect, caster)


## Does the actual work of adding a Status. Creates a StatusEffect from the given Effect.
func _add_status(effect: Effect, caster: Entity):
	var status_effect : StatusEffect = effect as StatusEffect
	if !status_effect:
		status_effect = status_effect_scene.instantiate().from_effect(effect)
	else :
		status_effect = status_effect_scene.instantiate().from_status_effect(status_effect)
	status_stacks[status_effect] = 1
	statuses.append(status_effect)
	add_child(status_effect)
	status_effect.on_lifetime_ended.connect(func(): _remove_status(status_effect))
	var targets : Array[Entity] = [entity]
	status_effect.register(caster, targets)
	on_status_added.emit(status_effect)


## Does the actual work of removing an Effect.
func _remove_status(status: StatusEffect):
	statuses.erase(status)
	status_stacks.erase(status)
	#effect.on_lifetime_ended.disconnect(func(): _remove_effect(effect)) ## Maybe not necessary?
	status.end()
	on_status_removed.emit(status)


### Constructs an Effect from the given resource and adds it.
#func add_effect_from_resource(
	#resource: EffectResource,
	#effect: Effect,
	#ability: Ability, 
	#caster: Entity, 
	#stacking_behavior: StatusAddEffectResource.StackingBehavior, 
	#lifetimes: Array[LifetimeResource], 
	#expiration_behavior: StatusAddEffectResource.ExpirationBehavior
#):
	#var targets : Array[Entity] = [entity]
	#var effect : StatusEffect = status_effect_scene.instantiate().from_resource(resource, caster, ability, targets)
	#add_effect(effect, caster, stacking_behavior)
