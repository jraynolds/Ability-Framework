extends ProgressBar
class_name AbilityCastBar
## Class for a bar that fills as an Entity uses an Ability.

@export var label : Label ## Label for the name of the ability being cast.
@export var animation_player : AnimationPlayer ## Animation Player for animations on this cast bar.

## The Entity whose casts we monitor. Setting this links events.
var entity : Entity :
	set(val):
		entity = val
		entity.abilities_component.on_ability_cast_begin.connect(func(a: Ability, _t: Array[Entity]): ability = a)
		entity.abilities_component.on_ability_cast.connect(func(_a: Ability, _t: Array[Entity]): ability = null)
		entity.abilities_component.on_ability_cast_interrupted.connect(interrupt)

## The Ability we're casting, if any. Setting this updates the UI.
var ability : Ability :
	set(val):
		DebugManager.debug_log(
			"Setting casting ability to " + (ability._title if ability else "null")
		, self)
		ability = val
		if animation_player.is_playing():
			animation_player.stop()
		if ability:
			label.text = ability._title

## Called when this node enters the scene.
func _ready() -> void:
	ability = null


## Called every frame. Updates the UI.
func _process(_delta):
	if animation_player.is_playing():
		visible = true
	elif ability and ability.casting_time > 0.0:
		visible = true
	else :
		visible = false
	if ability:
		var cast_time = ability.casting_time
		var cast_time_left = ability._cast_time_left 
		var bar_percent = (cast_time - cast_time_left) / cast_time
		value = bar_percent * 100


## Called when a cast ability is interrupted.
func interrupt(_ability: Ability, _target: Array[Entity], _source: Entity):
	ability = null
	if _source == entity:
		label.text = "Canceled."
		animation_player.play("flash_white")
	else :
		label.text = "Interrupted!"
		animation_player.play("flash_red")
