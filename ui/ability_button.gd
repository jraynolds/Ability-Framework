extends Button
## A button representing the player's Ability.
class_name AbilityButton

var ability : Ability : ## The Ability this button represents. Setting it changes the look.
	set(val):
		ability = val
		icon = ability._icon
		visible = val != null
var dragging : bool : ## Whether this button is currently being dragged. Setting it changes its visibility.
	set(val):
		dragging = val
		if dragging:
			modulate = Color(1, 1, 1, .6)
		else :
			modulate = Color(1, 1, 1, 1)


## Called when this node wakes up. Toggles visibility if there's no Ability.
func _ready() -> void:
	visible = ability != null
	#pass


## Called when dragged. Returns this object.
func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(make_drag_preview())
	dragging = true
	return self


## Used to make a preview for the ability.
func make_drag_preview() -> TextureRect:
	var preview_container := Control.new()
	var preview := TextureRect.new()
	preview.texture = icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = size
	preview_container.add_child(preview)
	preview.position = global_position - get_global_mouse_position()
	return preview_container


## Returns whether a draggable element can be dropped on this button.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return get_parent()._can_drop_data(_at_position, data)


## Drops the given data on this slot.
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	get_parent()._drop_data(_at_position, data)


## Called when a GUI notification occurs. If it's the end of a drag, sets dragging to false.
func _notification(notification_type): 
	match notification_type:
		NOTIFICATION_DRAG_END: 
			dragging = false
