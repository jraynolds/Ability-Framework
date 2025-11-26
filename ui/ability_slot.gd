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
@export var gcd_progress_bar : TextureProgressBar ## The progress overlay for an Ability in gcd cooldown.
@export var cooldown_progress_bar : TextureProgressBar ## The progress overlay for an Ability in cooldown.
var gcd_progress : float : ## What percent filled the GCD progress bar should be. Changing this fills the bar.
	set(val):
		assert(val >= 0.0 and val <= 100.0, "Can't set this value for our cooldown progress bar!")
		gcd_progress = val
		gcd_progress_bar.value = gcd_progress
		if button.ability:
			if button.ability._gcd_type != AbilityResource.GCD.OffGCD:
				gcd_progress_bar.visible = gcd_progress > 0
var cooldown_progress : float : ## What percent filled the cooldown progress bar should be. Changing this fills the bar.
	set(val):
		if val < 0.0:
			return
		assert(val >= 0.0 and val <= 100.0, "Can't set this value for our cooldown progress bar!")
		cooldown_progress = val
		cooldown_progress_bar.value = cooldown_progress
		cooldown_progress_bar.visible = button.ability.cooldown > 0.0 and button.ability._cooldown_left > 0.0
@export var animation_player : AnimationPlayer ## The animation player for this slot.
@export var highlight : TextureRect ## A highlight overlay for the button.
var highlighted : bool : ## Whether the contained Ability should be highlighted. Toggles the highlight.
	set(val):
		highlighted = val
		highlight.visible = highlighted
@export var activated_border : TextureRect ## A highlight overlay for the button that shows when it's been activated.
@export var disabled_overlay : TextureRect ## A dark overlay for the button that shows if the ability in it can be used.

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

#signal on_drop_accept(data: Variant) ## emitted when an element is successfully dropped on this slot.
signal on_activated ## emitted when the slot's keystroke is pressed.

## Custom init function so that it doesn't error
#func init(cms: Vector2) -> void:
	#custom_minimum_size = cms
	

## Called when this node comes alive. Sets the activation key to update the readout and sets visibility.
func _ready() -> void:
	set_key(key, shift, control, alt)
	gcd_progress_bar.visible = false
	cooldown_progress_bar.visible = false


## Called every frame. Checks whether the player can use the ability in the slot, and adds the disabled overlay if not.
func _process(_delta: float) -> void:
	if _button and _button.ability:
		disabled_overlay.visible = !GameManager.player_entity.abilities_component.can_cast(_button.ability)
		if _button.ability.cooldown != 0.0:
			var cooldown_left = _button.ability._cooldown_left
			var cooldown_total = _button.ability.cooldown
			cooldown_progress = (1 - ((cooldown_total - cooldown_left) / cooldown_total)) * 100
	#if slot._button.ability._gcd_type == AbilityResource.GCD.OffGCD:
		#cooldown_left = slot._button.ability._cooldown_left
		#cooldown_total = slot._button.ability.get_cooldown()
	#cooldown_percentage = (1 - ((cooldown_total - cooldown_left) / cooldown_total)) * 100


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
func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
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
	key = new_key
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
