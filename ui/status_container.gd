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
var _lifetime_left : float : ## How much time left in seconds the Effect has. Changing this sets the label.
	set(val):
		_lifetime_left = val
		if _lifetime_left <= 0:
			_lifetime_label.text = ""
		elif _lifetime_left < 1.0:
			_lifetime_label.text = str("%0.1f" % _lifetime_left)
		elif _lifetime_left >= 1.0: ## We specify this in case we get a NAN
			_lifetime_label.text = str(floori(_lifetime_left))
@export var _lifetime_label : Label ## The label that displays how much time left the Effect has.

var _status : StatusEffect : ## The StatusEffect this container is representing. Changing this updates our visuals.
	set(val):
		_status = val
		name = _status._title
		_button.icon = _status._icon
		_stacks_label.text = ""
		_lifetime_label.text = ""
		#_status.on_expired.connect(func(): _status = null)


## Constructs and returns an instance of this, initialized with the given status Effect.
func from_status(status: StatusEffect) -> StatusContainer:
	_status = status
	return self


## Called every frame. Updates the duration.
func _process(_delta: float) -> void:
	if !_status:
		return
	_lifetime_left = _status.lifetime_remaining


## Sets the number of stacks for our StatusEffect.
func set_stacks(stacks: int):
	_stacks = stacks
