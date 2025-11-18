extends ProgressBar
class_name AbilityCastBar
## Class for a bar that fills as an Entity uses an Ability.

@export var label : Label ## Label for the name of the ability being cast.

## The Entity whose casts we monitor. Setting this links events.
var entity : Entity :
	set(val):
		entity = val
		entity.abilities_component.on_ability_cast_begin.connect(func(a: Ability, _t: Array[Entity]): ability = a)
		entity.abilities_component.on_ability_cast.connect(func(_a: Ability, _t: Array[Entity]): ability = null)


## The Ability we're casting, if any. Setting this updates the UI.
var ability : Ability :
	set(val):
		DebugManager.debug_log(
			"Setting casting ability to " + (ability._title if ability else "null")
		, self)
		ability = val
		if ability:
			label.text = ability._title


## Called every frame. Updates the UI.
func _process(_delta):
	visible = true if ability else false
	if ability:
		var cast_time = ability.get_casting_time()
		var cast_time_left = ability._cast_time_left
		var bar_percent = (cast_time - cast_time_left) / cast_time
		value = bar_percent * 100
