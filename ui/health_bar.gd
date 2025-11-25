extends HBoxContainer
## A UI component for displaying health and entity information.
class_name HealthBar

var entity : Entity : ## The Entity this HealthBar represents. Changing this updates the UI.
	set(val):
		#var old_val = entity
		entity = val
		icon.texture = entity.icon
		name_label.text = entity.title
		_update_bars(entity.stats_component.get_stat_value(StatResource.StatType.HP))
		entity.stats_component.on_stat_change.connect(_on_stat_change)

@export var icon : TextureRect ## Icon for the Entity's picture.
@export var name_label : Label ## Label for the name of the Entity.
@export var hp_label : Label ## Label for the Entity's HP value.
@export var progress_bar_fast : ProgressBar ## HP bar that responds immediately.
@export var progress_bar_delayed : ProgressBar ## HP bar that responds after a delay.
@export var progress_bar_delay : float ## Delay in seconds before the slower HP bar responds.
@export var progress_bar_duration : float ## Duration in seconds the slower HP bar takes to finish updating.
var progress_bar_tween : Tween ## The Tweener that slowly modifies the delayed HP bar.

@export_enum("Up", "Down") var floating_text_direction = "Up" ## The direction floating text moves.
@export var floating_text : Label ## A Label that floats and disappears to mark HP changes.
@export var floating_text_distance : Vector2 = Vector2(0, 150) ## The vector floating text floats before it disappears.
@export var floating_text_lifetime : float = 1.5 ## How long in seconds floating text stays visible. 
@export var floating_text_max_jitter : Vector2 = Vector2(20, 20) ## The maximum positive or negative range floating text can spawn at.

## Called when our Entity's Stats change.
func _on_stat_change(stat: StatResource.StatType, new_val: float, old_val: float):
	if stat == StatResource.StatType.HP: 
		_update_bars(new_val, old_val)
		_spawn_floating_text(-old_val + new_val)
	elif stat == StatResource.StatType.MaxHP:
		_update_bars(entity.stats_component.get_stat_value(StatResource.StatType.HP))


## Updates the values and text for the HP bars.
func _update_bars(new_hp: float, _old_hp: float = 0):
	var entity_max_hp = entity.stats_component.get_stat_value(StatResource.StatType.MaxHP)
	hp_label.text = str(floori(new_hp)) + "/" + str(floori(entity_max_hp))
	var bar_value = new_hp / entity_max_hp * 100
	if progress_bar_tween and progress_bar_tween.is_running():
		progress_bar_tween.kill()
	progress_bar_fast.value = bar_value
	progress_bar_tween = get_tree().create_tween()
	progress_bar_tween.tween_property( ## Does nothing, to delay.
		progress_bar_delayed,
		"value",
		progress_bar_delayed.value,
		progress_bar_delay
	)
	progress_bar_tween.tween_property(
		progress_bar_delayed, 
		"value", 
		bar_value,
		progress_bar_duration
	)


## Spawns a floating Label that drifts, fades, and frees itself.
func _spawn_floating_text(difference: float):
	var floating_text_temp : Label = floating_text.duplicate(2) ## copies group
	progress_bar_fast.add_child(floating_text_temp)
	
	floating_text_temp.text = ""
	if difference > 0:
		floating_text_temp.modulate = Color.GREEN
		floating_text_temp.text = "+"
	elif difference == 0:
		floating_text_temp.modulate = Color.WHITE
	else :
		floating_text_temp.modulate = Color.RED
	floating_text_temp.text += str(floori(difference))
	
	floating_text_temp.position += Vector2(
		randf_range(-floating_text_max_jitter.x, floating_text_max_jitter.x),
		randf_range(-floating_text_max_jitter.y, floating_text_max_jitter.y)
	)
	#var floating_text_end_position = floating_text.position + floating_text_distance ## looked kind of neat
	var floating_text_end_position = floating_text_temp.position + floating_text_distance
	if floating_text_direction == "Up":
		floating_text_end_position -= 2 * floating_text_distance
	
	floating_text_temp.visible = true
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		floating_text_temp, 
		"position", 
		floating_text_end_position, 
		floating_text_lifetime
	)
	tween.tween_property(
		floating_text_temp, 
		"modulate", 
		Color(floating_text_temp.modulate, 0), 
		floating_text_lifetime
	).set_trans(Tween.TRANS_EXPO)
	tween.finished.connect(func(): floating_text_temp.queue_free(), 4)
