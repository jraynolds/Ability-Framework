extends ProgressBar
class_name AbilityCastBar
## Class for a bar that fills as an Entity uses an Ability.

@export var label : Label ## Label for the name of the ability being cast.
@export var animation_player : AnimationPlayer ## Animation Player for animations on this cast bar.

## The Entity whose casts we monitor. Setting this links events.
var entity : Entity :
	set(val):
		entity = val
		entity.abilities_component.on_ability_cast_begin.connect(func(a: Ability, _t: Array[Entity]): ability_casting = a)
		entity.abilities_component.on_ability_cast.connect(func(_a: Ability, _t: Array[Entity]): ability_casting = null)
		entity.abilities_component.on_ability_cast_interrupted.connect(interrupt)
		entity.abilities_component.on_ability_channel_begin.connect(func(a: Ability, _t: Array[Entity]): ability_channeling = a)
		entity.abilities_component.on_ability_channeled.connect(func(_a: Ability, _t: Array[Entity]): ability_channeling = null)


var ability_casting : Ability : ## The Ability we're casting, if any. Setting this updates the UI.
	set(val):
		DebugManager.debug_log(
			"Setting casting ability to " + (ability_casting._title if ability_casting else "null")
		, self)
		ability_casting = val
		if animation_player.is_playing():
			animation_player.stop()
		if ability_casting:
			label.text = ability_casting._title
var ability_channeling : Ability : ## The Ability we're channeling, if any. Setting this updates the UI.
	set(val):
		DebugManager.debug_log(
			"Setting channeling ability to " + (ability_channeling._title if ability_channeling else "null")
		, self)
		ability_channeling = val
		if animation_player.is_playing():
			animation_player.stop()
		if ability_channeling:
			label.text = ability_channeling._title


## Called when this node enters the scene.
func _ready() -> void:
	ability_casting = null
	ability_channeling = null


## Called every frame. Updates the UI.
func _process(_delta):
	if animation_player.is_playing():
		visible = true
	elif ability_casting and ability_casting.casting_time > 0.0:
		visible = true
	elif ability_channeling and ability_channeling.casting_time > 0.0:
		visible = true
	else :
		visible = false
	if ability_casting:
		var cast_time = ability_casting.casting_time
		var cast_time_left = ability_casting._cast_time_left 
		var bar_percent = (cast_time - cast_time_left) / cast_time
		value = bar_percent * 100
	elif ability_channeling:
		var max_channel_time = ability_channeling.max_channel_time
		var channel_time_left = ability_channeling._channel_time_left 
		var bar_percent = 1 - ((max_channel_time - channel_time_left) / max_channel_time)
		value = bar_percent * 100


## Called when a cast ability is interrupted.
func interrupt(_ability: Ability, _target: Array[Entity], _source: Entity):
	ability_casting = null
	if _source == entity:
		label.text = "Canceled."
		animation_player.play("flash_white")
	else :
		label.text = "Interrupted!"
		animation_player.play("flash_red")
