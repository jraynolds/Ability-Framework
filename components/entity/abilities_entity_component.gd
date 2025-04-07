extends EntityComponent
## An EntityComponent containing Abilities values and logic.
class_name AbilitiesEntityComponent

## The Abilities this Entity has, paired with the bar locations for each Ability. 
## The integer can be 0-19; 0 is "1", 10 is "+1"
var abilities : Dictionary[Ability, int]
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

@export var ability_scene : PackedScene ## The default Ability scene.

## Emitted when the GCD remaining value changes. Emits the remaining value and the total for this latest GCD.
signal on_gcd_update(gcd_remaining: float, gcd_total: float)
signal on_ability_cast(ability: Ability, targets: Array[Entity]) 

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
	gcd_remaining = 0


## Overloaded method for logic that happens when the Entity value is updated.
func on_entity_updated():
	pass

### Called when this node becomes active. Connects signals.
#func _ready() -> void:
	#entity.

## Updates every frame.
func _process(delta: float) -> void:
	if gcd_remaining > 0:
		gcd_remaining = max(0, gcd_remaining - delta)


## Tries to cast the given ability on the given targets.
func try_cast(ability: Ability, targets: Array[Entity]):
	if !can_cast(ability, targets):
		return
	cast(ability, targets)


## Casts the given ability on the given targets. Adds it to the heap of our casts.
func cast(ability: Ability, targets: Array[Entity]):
	ability.cast(targets)
	on_ability_cast.emit(ability, targets)
	if ability._gcd_type == AbilityResource.GCD.OnGCD:
		if ability._gcd_cooldown:
			gcd_max_cached = ability._gcd_cooldown.get_value(entity, targets)
			gcd_remaining = gcd_max_cached
		else :
			gcd_max_cached = entity.stats_component.get_stat_value(StatResource.StatType.GCD)
			gcd_remaining = gcd_max_cached


## Returns whether the given Ability can be cast by this Entity on the given targets.
func can_cast(ability: Ability, targets: Array[Entity]) -> bool:
	if gcd_remaining > 0 and ability._gcd_type == AbilityResource.GCD.OnGCD:
		return false
	return ability.is_castable(targets)
