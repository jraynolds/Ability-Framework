extends Node2D
## Class for the battle scene.
class_name Battle

@export var ability_overlay : AbilityOverlay ## The buttons overlay for the player.
@export var enemy_ability_overlay : SimpleAbilitiesContainer ## The simplistic ability overlay for the enemy.
@export var health_bar_enemy : HealthBar ## The health bar for the enemy.
@export var health_bar_player : HealthBar ## The health bar for the player.
@export var cast_bar_enemy : AbilityCastBar ## The cast bar for the enemy.
@export var cast_bar_player : AbilityCastBar ## The cast bar for the player.
@export var statuses_container_enemy_positive : StatusesContainer ## The container for the beneficial statuses on the enemy.
@export var statuses_container_enemy_negative: StatusesContainer ## The container for the detrimental statuses on the enemy.
@export var statuses_container_player_positive : StatusesContainer ## The container for the beneficial statuses on the player.
@export var statuses_container_player_negative : StatusesContainer ## The container for the detrimental statuses on the player.
@export var ability_graph : AbilityGraph ## The graph in the popup window showing the ability graph for the enemy.

var enemy : Entity : ## The enemy the player is fighting against. Changing this alters the UI.
	set(val):
		enemy = val
		enemy_ability_overlay.entity = enemy
		health_bar_enemy.entity = enemy
		statuses_container_enemy_positive.entity = enemy
		statuses_container_enemy_negative.entity = enemy
		enemy.targeting_component.targets = [player]
		cast_bar_enemy.entity = enemy
		ability_graph.entity = enemy
var player : Entity: ## The Entity the player controls. Changing this alters the UI.
	set(val):
		player = val
		health_bar_player.entity = player
		ability_overlay.entity = player
		statuses_container_player_positive.entity = player
		statuses_container_player_negative.entity = player
		player.targeting_component.targets = [enemy]
		cast_bar_player.entity = player
## How long in seconds the last pressed Ability is kept and cast if the GCD reaches 0 first. 
@export var queued_ability_duration : float
var queued_ability_duration_left : float ## How long in seconds we'll continue to remember the queued Ability.
## An array storing the queued Ability. When this is changed, updates our queue duration.
var queued_ability : Ability : 
	set(val):
		queued_ability = val
		if val:
			queued_ability_duration_left = queued_ability_duration

var active : bool : ## Whether the battle is currently active. Changing this emits events.
	set(val):
		var prev_val = active
		active = val
		DebugManager.debug_log(
			"Setting the battle active to " + str(val) + ", previously was " + str(prev_val)
		, self)
		if !prev_val and active:
			on_started.emit()
		elif prev_val and !active:
			on_ended.emit()
var paused : bool : ## Whether the battle is temporarily paused. Changing this emits events.
	set(val):
		var prev_val = paused
		paused = val
		DebugManager.debug_log(
			"Setting the battle pause state to " + str(val) + ", previously was " + str(prev_val)
		, self)
		if !prev_val and paused:
			on_paused.emit()
		elif prev_val and !paused:
			on_resumed.emit()

signal on_started ## Emitted when the battle starts.
signal on_paused ## Emitted when the battle pauses.
signal on_resumed ## Emitted when the battle resumes.
signal on_tick(delta: float) ## Emitted when the battle, when active, advances a frame.
signal on_ended ## Emitted when the battle ends.

## Called when this node becomes active. Connects signals.
func _ready() -> void:
	ability_overlay.on_ability_activated.connect(_on_ability_activated)


## Called every frame.
func _process(delta: float) -> void:
	if active and !paused:
		on_tick.emit(delta)
		player.on_battle_tick(delta)
		enemy.on_battle_tick(delta)
	
	for ability_slot in ability_overlay.ability_slots:
		var highlighted = false
		if ability_slot.button.ability:
			if ability_slot.button.ability._is_highlighted([enemy]):
				highlighted = true
		ability_slot.highlighted = highlighted
	
	if queued_ability_duration_left > 0:
		if queued_ability and player.abilities_component.gcd_remaining <= 0:
			player_cast(queued_ability)
		queued_ability_duration_left -= delta
		if queued_ability_duration_left <= 0:
			queued_ability = null
	
	#if enemy.abilities_component.gcd_remaining <= 0:
		#for ability in enemy.abilities_component.abilities:
			#if enemy.abilities_component.can_cast_at(ability, [player]):
				#enemy.abilities_component.cast(ability, [player])
				#return


## Called when unhandled keyboard input is received.
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Clear queued or cancel casting ability"):
		queued_ability = null
		if player.abilities_component.ability_casting:
			player.abilities_component.cancel_cast() 
		get_viewport().set_input_as_handled()
		DebugManager.debug_log(
			"Registering the cancel spellcast keypress"
		, self)
	elif event.is_action_pressed("Pause battle"):
		if active:
			paused = !paused
		get_viewport().set_input_as_handled()
		DebugManager.debug_log(
			"Registering the pause battle keypress"
		, self)


## Begins a battle between the given entities. Adds the Enemy entity as a child.
func start_battle(player_entity: Entity, enemy_entity: Entity):
	player = player_entity
	enemy = enemy_entity
	player.targeting_component.targets = [enemy]
	enemy.targeting_component.targets = [player]
	add_child(enemy)
	active = true
	DebugManager.debug_log(
		"Starting the battle"
	, self)


## Called when an Ability is activated by the player, usually by pressing 
func _on_ability_activated(caster: Entity, ability: Ability):
	if ability._gcd_type == AbilityResource.GCD.OnGCD and caster.abilities_component.gcd_remaining > 0:
		queued_ability = ability
	else :
		player_cast(ability)


## Sends the given Ability to the player so their AbilityComponent can try to cast it.
func player_cast(ability: Ability):
	var targets = ability.get_targets()
	player.abilities_component.try_cast(ability, targets)


func _on_ability_graph_window_close_requested() -> void:
	ability_graph.get_parent().queue_free()
