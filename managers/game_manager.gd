extends Node2D
## Class for game logic.

@export var player_entity_resource : EntityResource ## The Entity the player starts as.
var player_entity : Entity ## The instanced Entity the player currently is.
@export var temp_enemy_entity_resource : EntityResource
@export var entity_scene : PackedScene ## The default Entity scene

@export var battle_scene : PackedScene ## The Battle scene
var battle : Battle ## The instanced Battle scene

## Called when this node is loaded.
func _ready() -> void:
	#pass
	player_entity = entity_scene.instantiate()
	add_child(player_entity)
	player_entity.resource = player_entity_resource
	player_entity.name = "Player"
	
	var enemy_entity : Entity = entity_scene.instantiate()
	enemy_entity.resource = temp_enemy_entity_resource
	
	battle = battle_scene.instantiate()
	add_child(battle)
	battle.start_battle(player_entity, enemy_entity)
