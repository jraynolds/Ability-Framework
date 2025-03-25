extends PanelContainer
## UI slot for a draggable Ability button.
class_name AbilitySlot

@export var _button : AbilityButton ## The Ability button in this slot.
var button : AbilityButton :
	get :
		return _button
	set(val):
		## If we have a button, remove it
		if _button:
			_button.get_parent().remove_child(_button)
		var val_parent = val.get_parent() if val else null
		if val_parent and val_parent != self: ## If the incoming button has a parent, remove it
			val_parent._button = null
			val_parent.remove_child(val)
		add_child(val) ## Add the incoming button
		if _button and val_parent: ## If we have a button and the incoming has a parent, send our button
			val_parent.button = _button
		_button = val
@export var key_label : Label ## The Label that depicts the keystroke that activates this slot.
@export var progress_bar : TextureProgressBar ## The progress overlay for an Ability in cooldown.
var progress : float : ## What percent filled the cooldown progress bar should be. Changing this fills the bar.
	set(val):
		assert(val >= 0.0 and val <= 100.0, "Can't set this value for our cooldown progress bar!")
		progress = val
		progress_bar.value = progress
		progress_bar.visible = progress > 0
@export var animation_player : AnimationPlayer ## The animation player for this slot.
@export var highlight : TextureRect ## A highlight overlay for the button.
var highlighted : bool : ## Whether the contained Ability should be highlighted. Toggles the highlight.
	set(val):
		highlighted = val
		highlight.visible = highlighted
@export var activated_border : TextureRect ## A highlight overlay for the button that shows when it's been activated.

@export var locked : bool ## Whether this slot can be dropped on.
@export var key : Key ## The keystroke that activates this slot.
@export var shift : bool ## Whether the Shift modifier is required to activate this slot.
@export var control : bool ## Whether the Control modifier is required to activate this slot.
@export var alt : bool ## Whether the Alt modifier is required to activate this slot.
var activated : bool : ## Whether the button is currently activated. When set to true, emits on_actived.
	set(val):
		var old_val = activated
		activated = val
		if val and not old_val:
			on_activated.emit()
			animation_player.stop()
			animation_player.play("activated_flash")

signal on_drop_accept(data: Variant) ## emitted when an element is successfully dropped on this slot.
signal on_activated ## emitted when the slot's keystroke is pressed.

## Custom init function so that it doesn't error
#func init(cms: Vector2) -> void:
	#custom_minimum_size = cms
	

## Called when this node comes alive. Sets the activation key to update the readout and sets visibility.
func _ready() -> void:
	set_key(key, shift, control, alt)
	progress_bar.visible = false


## Called when an unconsumed input event is heard. 
## If it matches our activation key, we consume the event and emit on_activated.
func _unhandled_key_input(event: InputEvent) -> void:
	var key_event = event as InputEventKey
	if !key_event:
		return
	if !key_event:
		return
	if key_event.keycode != key:
		return
	if shift != key_event.shift_pressed:
		return
	if control != key_event.is_command_or_control_pressed():
		return
	activated = key_event.pressed
	get_viewport().set_input_as_handled()


## Returns whether a draggable element can be dropped on this slot.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if locked:
		return false
	if button:
		return true
	else :
		return true


## Drops the given data on this slot.
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if locked:
		return
	button = data as AbilityButton


## Sets our activation keypress and updates the label.
func set_key(new_key: Key, new_shift: bool, new_control: bool, new_alt: bool):
	key = key
	shift = new_shift
	control = new_control
	alt = new_alt
	var new_label := ""
	if shift:
		new_label += "+"
	if control:
		new_label += "^"
	if alt:
		new_label += "!"
	new_label += OS.get_keycode_string(key)
	key_label.text = new_label
