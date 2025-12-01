extends PanelContainer
## UI for a Container that shows the an Entity's Abilities and a cooldown in a simplistic manner.
class_name SimpleAbilitiesContainer

@export var abilities_container : VBoxContainer ## The container for the individual Ability buttons.
@export var ability_button_scene : PackedScene ## The default PackedScene for a simplistic AbilityButton.
@export var gcd_cooldown_bar : TextureProgressBar ## The TextureProgressBar for the entity's GCD.

var entity : Entity : ## The Entity whose Abilities we watch.
	set(val):
		var old_val = entity
		entity = val
		for child in abilities_container.get_children():
			child.queue_free()
		if entity:
			for ability in entity.abilities_component.abilities:
				var button = ability_button_scene.instantiate() as SimpleAbilityButton
				abilities_container.add_child(button)
				button.ability = ability
			entity.abilities_component.on_gcd_update.connect(_on_entity_gcd_update)
		if old_val:
			old_val.abilities_component.on_gcd_update.disconnect(_on_entity_gcd_update)

## Called when the connected Entity's GCD updates. Changes the value of the GCD cooldown overlay.
func _on_entity_gcd_update(gcd_remaining: float, gcd_total: float):
	gcd_cooldown_bar.value = (1 - (gcd_total - gcd_remaining) / gcd_total) * 100
