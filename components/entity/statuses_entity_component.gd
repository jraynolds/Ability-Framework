extends EntityComponent
## An EntityComponent containing Statuses values and logic.
class_name StatusesEntityComponent

## The Array of Effects ongoing on this Entity, ordered by when they were added.
var statuses : Array[StatusEffect]
## The Dictionary of Effects ongoing on this Entity, paired with how many stacks of the same Effect exist.
var status_stacks : Dictionary[StatusEffect, int] = {} 
@export var initial_statuses : Array[StatusAddEffectResource] ## Statuses the Entity begins with can be added here.
@export var status_effect_scene : PackedScene ## A default StatusEffect scene in case we have to construct one.

var stat_transform_statuses : Array[StatusEffect] : ## The statuses that transform changes made to stats.
	get :
		return entity.statuses_component.statuses.filter(func(status: StatusEffect): 
			return status._resource as StatTransformEffectResource
		)
var keyword_transform_statuses : Array[StatusEffect] : ## The statuses that transform changes made to keywords.
	get :
		return entity.statuses_component.statuses.filter(func(status: StatusEffect): 
			return status._resource as KeywordTransformEffectResource
		)

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
		)
		add_status(status_effect, null, null, entity, status.stacking_behavior)


## Called every frame. Increments duration for all attached status Effects.
func _process(delta: float) -> void:
	for status in statuses:
		status._time_active += delta


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
		if effect_resource == status._resource:
			return status
	return null


## Returns an array of StatusEffects matching the given positivity.
func get_statuses(status_positivity: Math.Positivity) -> Array[Effect]:
	var matching_statuses : Array[Effect] = []
	for status in statuses:
		if status._positivity == status_positivity:
			matching_statuses.append(status)
	return matching_statuses


## Adds a given Effect with the given stacking behavior and given stacks (by default, 1).
func add_status(
	status: StatusEffect,
	adding_effect: Effect,
	adding_ability: Ability,
	caster: Entity,
	stacking_behavior: StatusAddEffectResource.StackingBehavior,
	num_stacks: int = 1
):
	assert(num_stacks > 0, "Trying to add negative--or zero--stacks of something!")
	DebugManager.debug_log(
		"Adding status " + status._title + " from effect '" + adding_effect._title + "' via ability '" + adding_ability._title +
		"' cast by " + caster.title + " with stacking behavior " + Natives.enum_name(StatusAddEffectResource.StackingBehavior, stacking_behavior) +
		" with " + str(num_stacks) + " stacks",
		self
	)
	var duplicate_effect = get_status(status)
	if !duplicate_effect:
		var new_status = _add_status(status, caster)
		status_stacks[new_status] = num_stacks
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
			duplicate_effect.end() ## Potential issues here.
			_add_status(status, caster)
			status_stacks[status] = stacks + num_stacks
		StatusAddEffectResource.StackingBehavior.Subtract:
			status_stacks[duplicate_effect] -= num_stacks
			if status_stacks[duplicate_effect] <= 0:
				duplicate_effect.end()
		StatusAddEffectResource.StackingBehavior.Replace:
			remove_status(duplicate_effect)
			status_stacks[_add_status(status, caster)] = num_stacks


## Does the actual work of adding a Status. Creates a StatusEffect from the given Effect and lifetime, adds it, and returns it.
func _add_status(status: StatusEffect, caster: Entity) -> StatusEffect:
	DebugManager.debug_log(
		"Creating a status effect from " + status._title + " and adding it to " + entity.title + "'s statuses",
		self
	)
	var status_effect = status_effect_scene.instantiate().from_status_effect(status)
	status_stacks[status_effect] = 1
	statuses.append(status_effect)
	add_child(status_effect)
	status_effect.on_expired.connect(func(): remove_status(status_effect))
	var targets : Array[Entity] = [entity]
	status_effect.register(caster, targets)
	on_status_added.emit(status_effect)
	return status_effect


## Converts the given Effect into a StatusEffect and removes it.
func remove_effect(effect: Effect):
	var status = effect as StatusEffect
	assert(status, "This effect is not a Status!")
	remove_status(status)


## Removes a StatusEffect. Called AFTER the status expires.
func remove_status(status: StatusEffect):
	DebugManager.debug_log(
		"Removing status " + status._title + " from entity " + entity.title,
		self
	)
	statuses.erase(status)
	status_stacks.erase(status)
	#effect.on_lifetime_ended.disconnect(func(): _remove_effect(effect)) ## Maybe not necessary?
	on_status_removed.emit(status)


## Modifies the given status's stacks by adding the given amount to them.
func modify_stacks(status: StatusEffect, amount: int) -> int:
	DebugManager.debug_log(
		"Modifying the number of stacks for status " + status._title + " on " + entity.title + " by " + str(amount),
		self
	)
	var matching_status = get_status(status)
	assert(matching_status, "But we don't have that status to alter its stacks!")
	status_stacks[matching_status] += amount
	if status_stacks[matching_status] <= 0:
		DebugManager.debug_log(
			"Status " + status._title + " on " + entity.title + " ran out of stacks and is ending",
			self
		)
		#remove_status(matching_status)
		matching_status.end()
		return NAN
	return status_stacks[matching_status]


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
