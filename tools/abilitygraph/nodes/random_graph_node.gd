extends GraphNodeBase
## Traverses to a random port, based on the weight given.
class_name RandomGraphNode

## Called when this node enters the scene.
func _ready() -> void:
	super()
	set_slot(1, false, 0, colors[0], true, 0, colors[0])
	set_slot(2, false, 0, colors[0], true, 0, colors[1])
	### Necessary to fix ordering issues
	var button_container = slot_button_add.get_parent()
	remove_child(button_container)
	slots[-1].add_sibling(button_container)


## Called when the battle proceeds to the next frame. Chooses a random output port based on the weights.
func tick(_delta: float):
	var max_rolling_slot_index : int = 1
	var max_roll : float = 0.0
	for i in range(len(slots)):
		var spin_box = slots[i] as SpinBox
		if spin_box:
			for j in range(spin_box.value):
				var roll = randf()
				if roll > max_roll:
					max_rolling_slot_index = i + 1
					max_roll = roll
	
	on_proceed.emit(max_rolling_slot_index)
	modulate = colors[max_rolling_slot_index]


## Called to save this node into the given Resource for later retrieval.
func save(resource: AbilityGraphNodeResource):
	super(resource)
	resource.node_data.num_slots = len(slots)
	resource.node_data.weights = []
	for i in range(len(slots)):
		var spin_box = slots[i] as SpinBox
		if spin_box:
			resource.node_data.weights.append(spin_box.value)


## Called to load into this node with the given resource.
func load(resource: AbilityGraphNodeResource):
	super(resource)
	resource.node_data.num_slots = len(slots)
	for i in range(resource.node_data.num_slots - 3):
		add_slot()
	for i in range(len(slots)):
		if i == 0:
			continue
		var spin_box = slots[i] as SpinBox
		spin_box.value = slots[i-1]
