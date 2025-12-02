extends GraphNodeBase
## Traverses to a random port, based on the weight given.
class_name RandomGraphNode

var weights : Array[int] : ## The weights on each of our output ports.
	get :
		var out = []
		for spin_box in spin_box_slots:
			out.append(spin_box.value)
		return out
var spin_box_slots : Array[SpinBox] : ## Our slots that are also spin boxes.
	get :
		return slots.filter(func(s: Control): return s as SpinBox)

## Called when this node enters the scene.
func _ready() -> void:
	add_slot()
	add_slot()


## Called when the battle proceeds to the next frame. Chooses a random output port based on the weights.
func tick(_delta: float):
	var max_rolling_slot_index : int = 1
	var max_roll : float = 0.0
	
	for i in range(spin_box_slots):
		for j in range(weights[i]):
			var roll = randf()
			if roll > max_roll:
				max_rolling_slot_index = i
				max_roll = roll
	
	on_proceed.emit(max_rolling_slot_index + 1)
	modulate = colors[max_rolling_slot_index]
