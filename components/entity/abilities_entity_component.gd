extends EntityComponent
## An EntityComponent containing Abilities values and logic.
class_name AbilitiesEntityComponent

## The Abilities this Entity has, paired with the bar locations for each Ability. 
## The integer can be 0-19; 0 is "1", 10 is "+1"
var abilities : Dictionary[Ability, int]

var ability_casting : Ability ## The Ability the Entity is currently casting, if any.
var ability_channeling : Ability ## The Ability the Entity is currently channeling, if any.

var gcd_remaining : float : ## The time in seconds before the global cooldown is ready again.
	set(val):
		var old_val = gcd_remaining
		gcd_remaining = val
		if gcd_remaining != old_val:
			on_gcd_update.emit(gcd_remaining, gcd_max_cached)
var gcd : float : ## The total duration in seconds a global cooldown ability disables others like it.
	get :
		return entity.stats_component.get_stat_value(StatResource.StatType.GCD)
var gcd_max_cached : float ## The stored GCD duration for the last Ability cast.
var can_act : bool = true ## Whether the Entity can act or not.

@export var ability_scene : PackedScene ## The default Ability scene.

## Emitted when the GCD remaining value changes. Emits the remaining value and the total for this latest GCD.
signal on_gcd_update(gcd_remaining: float, gcd_total: float)
## Emitted when the Entity begins to cast an Ability.
signal on_ability_cast_begin(ability: Ability, targets: Array[Entity])
## Emitted when the Entity's ongoing Ability cast is interrupted or canceled.
signal on_ability_cast_interrupted(ability: Ability, targets: Array[Entity], interrupter: Entity)
## Emitted when the Entity successfully casts an Ability.
signal on_ability_cast(ability: Ability, targets: Array[Entity])
## Emitted when the Entity begins to channel an Ability.
signal on_ability_channel_begin(ability: Ability, targets: Array[Entity])
## Emitted when the Entity's ongoing Ability channel is interrupted or canceled.
#signal on_ability_channel_interrupted(ability: Ability, targets: Array[Entity], interrupter: Entity)
## Emitted when the Entity successfully finishes channeling an Ability.
signal on_ability_channeled(ability: Ability, targets: Array[Entity])

## Overloaded method for logic that happens when the Entity's resource is changed.
## We rebuild from the ground up, so don't do this unless you want to wipe instanced changes.
## Intializes Ability objects.
func load_entity_resource(resource: EntityResource):
	abilities = {}
	for ability_resource in resource.abilities.keys():
		var ability : Ability = ability_scene.instantiate().from_resource(ability_resource, entity)
		abilities[ability] = resource.abilities[ability_resource]
		add_child(ability)
		ability.name = ability._title
		connect_signals(ability)
	gcd_remaining = 0


## Overloaded method for logic that happens when the Entity value is updated.
func on_entity_updated():
	pass


## Overloadable function for logic that happens every time the battle advances a frame.
## Reduces GCDs and propagates to our Abilities.
func on_battle_tick(delta: float):
	if gcd_remaining > 0:
		gcd_remaining = max(0, gcd_remaining - delta)
	for ability in abilities:
		ability.on_battle_tick(delta)


## Connects an Ability's signals to our functions.
func connect_signals(ability: Ability):
	ability.on_cast.connect(func(_caster: Entity, targets: Array[Entity]): _on_ability_finished_cast(ability, targets))
	ability.on_channel_ended.connect(func(_caster: Entity, targets: Array[Entity]): _on_ability_finished_channel(ability, targets))


## Returns the Ability that matches the given AbilityResource.
func get_ability_by_resource(resource: AbilityResource):
	for ability in abilities:
		if ability.is_resource_equal(resource):
			return ability
	return null


## Tries to cast the given ability on the given targets.
func try_cast(ability: Ability, targets: Array[Entity]):
	if !can_cast_at(ability, targets):
		return
	cast(ability, targets)


## Begins to cast the given ability on the given targets.
func cast(ability: Ability, targets: Array[Entity]):
	DebugManager.debug_log(
		"Entity " + entity.title + " is beginning to cast ability " + ability._title +
		" at targets " + ",".join(targets.map(func(t: Entity): return t.title))
	, self)
	on_ability_cast_begin.emit(ability, targets)
	ability_casting = ability
	#ability.on_cast.connect(
		#func(_caster: Entity, t: Array[Entity]): _on_ability_finished_cast(ability, t), 4
	#) ##TODO fix interrupt interaction
	ability.begin_cast(targets)
	
	if ability._gcd_type == AbilityResource.GCD.OnGCD:
		if ability._gcd_cooldown:
			gcd_max_cached = ability._gcd_cooldown.get_value(entity, targets)
			gcd_remaining = gcd_max_cached
		else :
			gcd_max_cached = entity.stats_component.get_stat_value(StatResource.StatType.GCD)
			gcd_remaining = gcd_max_cached


## Triggered when an Ability we've begun to cast has finished casting.
func _on_ability_finished_cast(ability: Ability, targets: Array[Entity]):
	DebugManager.debug_log(
		"Entity " + entity.title + " has successfully finished casting ability " + ability._title +
		" at targets " + ",".join(targets.map(func(t: Entity): return t.title))
	, self)
	ability_casting = null
	on_ability_cast.emit(ability, targets)
	if ability.max_channel_time > 0.0:
		channel(ability, targets)
	else :
		ability.end()


## Begins to channel the given Ability at the given targets.
func channel(ability: Ability, targets: Array[Entity]):
	DebugManager.debug_log(
		"Entity " + entity.title + " is beginning to channel ability " + ability._title +
		" at targets " + ",".join(targets.map(func(t: Entity): return t.title))
	, self)
	ability_channeling = ability
	on_ability_channel_begin.emit(ability, targets)
	ability.channel()


## Triggered when an Ability we've begun to channel has finished channeling.
func _on_ability_finished_channel(ability: Ability, targets: Array[Entity]):
	DebugManager.debug_log(
		"Entity " + entity.title + " has successfully finished channeling ability " + ability._title +
		" at targets " + ",".join(targets.map(func(t: Entity): return t.title))
	, self)
	ability_channeling = null
	on_ability_channeled.emit(ability, targets)
	ability.end()


## Returns whether the given Ability can be cast by this Entity.
func can_cast(ability: Ability) -> bool:
	if !can_act:
		return false
	if ability_casting:
		return false
	if ability_channeling:
		return false
	if gcd_remaining > 0 and ability._gcd_type == AbilityResource.GCD.OnGCD:
		return false
	if ability._cooldown_left > 0.0:
		return false
	return ability.is_castable()


## Returns whether the given Ability can be cast by this Entity on the given targets.
func can_cast_at(ability: Ability, targets: Array[Entity]) -> bool:
	if !can_act:
		return false
	if ability_casting:
		return false
	if ability_channeling:
		return false
	if gcd_remaining > 0 and ability._gcd_type == AbilityResource.GCD.OnGCD:
		return false
	if ability._cooldown_left > 0.0:
		return false
	return ability.is_castable_at(targets)


## Modifies the remaining cooldowns on this Entity's abilities by the given number, using the given math operation.
func modify_cooldowns(amount: float, operation: Math.Operation):
	for ability in abilities:
		ability._cooldown_left = Math.perform_operation(ability._cooldown_left, amount, operation)


## Stops the active cast ability.
func cancel_cast():
	if ability_casting:
		DebugManager.debug_log(
			"Entity " + entity.title + " is canceling its cast of ability " + ability_casting._title
		, self)
		ability_casting.cancel_cast()
		on_ability_cast_interrupted.emit(ability_casting, ability_casting.get_targets(), entity)
		ability_casting = null
