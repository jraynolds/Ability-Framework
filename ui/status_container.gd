extends VBoxContainer
## Ui component for displaying an Entity's active status Effect.
class_name StatusContainer

@export var _button : Button ## The button with the Effect texture.
var _stacks : int : ## The number of stacks this status Effect has. Changing this sets the label.
	set(val):
		_stacks = val
		if _stacks <= 1:
			_stacks_label.text = ""
		else :
			_stacks_label.text = str(_stacks)
@export var _stacks_label : Label ## The label that displays how many stacks the status Effect has.
var _duration : float : ## How much time left in seconds the Effect has. Changing this sets the label.
	set(val):
		_duration = val
		if _duration <= 0:
			_duration_label.text = ""
		elif _duration < 1.0:
			_duration_label.text = str("%0.1f" % _duration)
		else :
			_duration_label.text = str(floori(_duration))
@export var _duration_label : Label ## The label that displays how much time left the Effect has.

var _effect : Effect : ## The Effect this container is representing. Changing this updates our visuals.
	set(val):
		_effect = val
		name = _effect._title
		_button.icon = _effect._icon
		_stacks_label.text = ""
		_duration_label.text = ""


## Constructs and returns an instance of this, initialized with the given status Effect.
func from_status(status: Effect) -> StatusContainer:
	_effect = status
	return self


## Called every frame. Updates the duration.
func _process(delta: float) -> void:
	if !_effect:
		return
	_duration = _effect.get_lifetime_duration_left()


func set_stacks(stacks: int):
	_stacks = stacks
