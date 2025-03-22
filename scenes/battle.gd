extends Node2D
## Class for the battle scene.
class_name Battle

@export var ability_overlay : AbilityOverlay
@export var health_bar_enemy : HealthBar
@export var health_bar_player : HealthBar

var enemy : Entity : ## The enemy the player is fighting against. Changing this alters the UI.
	set(val):
		enemy = val
		health_bar_enemy.entity = enemy
var player : Entity: ## The Entity the player controls. Changing this alters the UI.
	set(val):
		player = val
		health_bar_player.entity = player
		ability_overlay.entity = player


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
			if ability_slot.button.ability._is_highlighted(player, [enemy]):
				highlighted = true
		ability_slot.highlighted = highlighted


## Begins a battle between the given entities. Adds the Enemy entity as a child.
func start_battle(player_entity: Entity, enemy_entity: Entity):
	player = player_entity
	enemy = enemy_entity
	add_child(enemy)
