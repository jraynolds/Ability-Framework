extends Button
## Class for a UI button depicting an Ability with only a name and cooldown.
class_name SimpleAbilityButton

@export var cooldown_bar : TextureProgressBar ## The progress bar that depicts the indivual Ability's cooldown.

var ability : Ability : ## The Ability we're watching.
	set(val):
		#var old_val = ability
		ability = val
		text = ability._title

## Called every frame. Updates the progress bar.
func _process(_delta: float) -> void:
	if ability:
		if ability.cooldown:
			cooldown_bar.value = (1 - ((ability.cooldown - ability._cooldown_left) / ability.cooldown)) * 100
