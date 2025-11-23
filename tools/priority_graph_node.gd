extends GraphNodeBase
class_name PriorityGraphNode
## From top to bottom, each of the Abilities attached to this priority node are tested to see if they can be cast.
## The first one that can, is.

var num_slots = 0 ## How many slots this node has.
@export var remove_slot_button : Button ## A button that removes a new slot.
@export var add_slot_button : Button ## A button that adds a new slot.

var graph_edit : GraphEdit : ## The graph edit parent of this node.
	get :
		return get_parent() as GraphEdit

## Called when the node enters the scene.
func _ready() -> void:
	super()
	set_slot(1, false, 0, Color.PURPLE, true, 0, Color(Color.GREEN, 1.0))
	set_slot(2, false, 0, Color.PURPLE, true, 0, Color(Color.GREEN, .9))
	num_slots = 3


## Called when the "add slot" button is pressed. Adds a slot.
func _on_add_slot_pressed():
	num_slots += 1
	var new_label = Label.new()
	new_label.text = str(num_slots - 1)
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	get_children()[-2].add_sibling(new_label)
	set_slot(
		num_slots-1, false, 0, Color.PURPLE, true, 0, Color(
			Color.GREEN, maxf(
				1.2 - (num_slots * .1), .1
			)
		)
	)
	if num_slots > 3:
		remove_slot_button.disabled = false


## Called when the "remove slot" button is pressed. Removes a slot.
func _on_remove_slot_pressed():
	num_slots -= 1
	for connection in graph_edit.connections:
		if connection.from_node == name:
			if connection.from_port == num_slots - 1:
				graph_edit.disconnect_node(name, connection.from_port, connection.to_node, connection.to_port)
	set_slot(num_slots, false, 0, Color.PURPLE, false, 0, Color(Color.GREEN, 1.0))
	remove_child(get_children()[-2])
	if num_slots <= 3:
		remove_slot_button.disabled = true
	get_rect().size = get_minimum_size()


## Called to save this node into the given Resource for later retrieval.
func save(resource: AbilityGraphNodeResource): 
	super(resource)
	resource.node_data.num_slots = num_slots


## Called to load into this node with the given resource.
func load(resource: AbilityGraphNodeResource):
	super(resource)
	for i in range(resource.node_data.num_slots - num_slots):
		_on_add_slot_pressed()
