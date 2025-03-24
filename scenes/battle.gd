extends Node2D
## Class for the battle scene.
class_name Battle

@export var ability_overlay : AbilityOverlay
@export var health_bar_enemy : HealthBar
@export var health_bar_player : HealthBar
@export var statuses_container_enemy_positive : StatusesContainer
@export var statuses_container_enemy_negative: StatusesContainer
@export var statuses_container_player_positive : StatusesContainer
@export var statuses_container_player_negative : StatusesContainer

var enemy : Entity : ## The enemy the player is fighting against. Changing this alters the UI.
	set(val):
		enemy = val
		health_bar_enemy.entity = enemy
		statuses_container_enemy_positive.entity = enemy
		statuses_container_enemy_negative.entity = enemy
var player : Entity: ## The Entity the player controls. Changing this alters the UI.
	set(val):
		player = val
		health_bar_player.entity = player
		ability_overlay.entity = player
		statuses_container_player_positive.entity = player
		statuses_container_player_negative.entity = player
## How long in seconds the last pressed Ability is kept and cast if the GCD reaches 0 first. 
@export var queued_ability_duration : float
var queued_ability_duration_left : float ## How long in seconds we'll continue to remember the queued Ability.
## An array storing the queued Ability. When this is changed, updates our queue duration.
var queued_ability : Ability : 
	set(val):
		queued_ability = val
		if val:
			queued_ability_duration_left = queued_ability_duration


## Called when this node becomes active. Connects signals.
func _ready() -> void:
	ability_overlay.on_ability_activated.connect(_on_ability_activated)


## Called every frame.
func _process(delta: float) -> void:
	for ability_slot in ability_overlay.ability_slots:
		var highlighted = false
		if ability_slot.button.ability:
			if ability_slot.button.ability._is_highlighted([enemy]):
				highlighted = true
		ability_slot.highlighted = highlighted
	
	if queued_ability_duration_left > 0:
		print(queued_ability_duration_left)
		if queued_ability and player.abilities_component.gcd_remaining <= 0:
			player.abilities_component.try_cast(queued_ability, [enemy])
		queued_ability_duration_left -= delta
		if queued_ability_duration_left <= 0:
			queued_ability = null


## Called when unhandled keyboard input is received.
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Clear queued Ability"):
		queued_ability = null
		get_viewport().set_input_as_handled()


## Begins a battle between the given entities. Adds the Enemy entity as a child.
func start_battle(player_entity: Entity, enemy_entity: Entity):
	player = player_entity
	enemy = enemy_entity
	add_child(enemy)


func _on_ability_activated(caster: Entity, ability: Ability):
	if ability._gcd_type == AbilityResource.GCD.OnGCD and caster.abilities_component.gcd_remaining > 0:
		queued_ability = ability
	else :
		player.abilities_component.try_cast(ability, [enemy])
