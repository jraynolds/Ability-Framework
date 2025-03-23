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


## Called when this node becomes active. Connects signals.
func _ready() -> void:
	ability_overlay.on_ability_cast.connect(
		func(caster: Entity, ability: Ability): player.abilities_component.cast(ability, [enemy])
	)


## Called every frame.
func _process(delta: float) -> void:
	for ability_slot in ability_overlay.ability_slots:
		var highlighted = false
		if ability_slot.button.ability:
			if ability_slot.button.ability._is_highlighted([enemy]):
				highlighted = true
		ability_slot.highlighted = highlighted


## Begins a battle between the given entities. Adds the Enemy entity as a child.
func start_battle(player_entity: Entity, enemy_entity: Entity):
	player = player_entity
	enemy = enemy_entity
	add_child(enemy)
