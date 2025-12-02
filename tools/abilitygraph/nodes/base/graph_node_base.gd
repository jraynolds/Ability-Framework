extends GraphNode
## Base class for a GraphNode in an AbilityGraph.
## Optionally, has an option dropdown.
## Optionally, allows you to add more slots.
class_name GraphNodeBase

var graph_edit : GraphEdit : ## The graph edit parent of this node.
	get :
		return get_parent() as GraphEdit

@export var option_button : OptionButton ## The dropdown menu we offer. By default, disabled.
@export var animation_player : AnimationPlayer ## The animation player for this node.
var entity : Entity ## The Entity this AbilityGraph is for.
var active : bool : ## Whether the AI brain is on this node.
	set(val):
		active = val
		if val and !animation_player.is_playing():
			animation_player.play("pulsate")
		elif !val:
			animation_player.stop()

@export var slots : Array[Control] ## An Array of the slots this graph node has, including the default.
@export var min_slots : int = 2 ## The minimum number of output slots. If at least our starting amount, we can't remove any.
@export var max_slots : int = 99 ## The maximum number of slots. If this is the same as the minimum, we can't add any more.
@export var slot_object : Control ## The slot object we add.
@export var slot_button_add : Button ## The button that gives us another slot.
@export var slot_button_remove : Button ## The button that removes the last slot.
## An array of colors to use for outgoing ports.
@export var colors : Array[Color] = [ 
	Color.GREEN, 
	Color.BLUE, 
	Color.PURPLE, 
	Color.YELLOW, 
	Color.ORANGE, 
	Color.RED, 
	Color.TURQUOISE, 
	Color.YELLOW_GREEN,
	Color.BROWN,
	Color.FUCHSIA,
	Color.WHITE 
]

signal on_proceed(port: int) ## Emitted when we're ready to proceed along a connection.

## Called when this node enters the scene. Creates our input slot, which by default has no output port.
func _ready() -> void:
	set_slot(0, true, 0, Color.PURPLE, false, 0, Color.RED)


## Initializes much of our setup. Overloadable.
func set_entity(e: Entity):
	entity = e


## Returns all file paths in the project.
func get_all_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths


## Called when a resize request is made on this GraphNode.
func _on_resize_request(new_size: Vector2) -> void:
	get_rect().size = new_size


## Adds a slot Control with the given ports and output color.
func add_slot(has_input: bool=false, has_output: bool=true, output_color: Color=colors[len(slots)]):
	var node = slot_object.duplicate()
	slots.append(node)
	slots[-1].add_sibling(node)
	set_slot(len(slots), has_input, 0, Color.PURPLE, has_output, 0, output_color)
	if len(slots) > min_slots:
		slot_button_remove.disabled = false
	if len(slots) == max_slots:
		slot_button_add.disabled = true
	get_rect().size = get_minimum_size()


## Removes the last slot Control.
func remove_last_slot():
	for connection in graph_edit.connections:
			if connection.from_node == name:
				if connection.from_port == len(slots) - 1:
					graph_edit.disconnect_node(name, connection.from_port, connection.to_node, connection.to_port)
	#set_slot(len(slots), false, 0, Color.PURPLE, false, 0, Color(Color.GREEN, 1.0))
	remove_child(slots.pop_back())
	if len(slots) == min_slots:
		slot_button_remove.disabled = true
	if len(slots) < max_slots:
		slot_button_add.disabled = false


## Called when the "add slot" button is pressed. Adds a slot.
func _on_add_slot_pressed():
	add_slot()


## Called when the "remove slot" button is pressed. Removes a slot.
func _on_remove_slot_pressed():
	remove_last_slot()


## Called when the battle proceeds to the next frame. Proceeds through the graph along the first output port. Meant to be overloaded.
func tick(_delta: float):
	on_proceed.emit(0)
	modulate = Color.PURPLE


## Called to save this node into the given Resource for later retrieval. Meant to be overloaded.
func save(resource: AbilityGraphNodeResource):
	resource.title = name
	resource.position_offset = position_offset


## Called to load into this node with the given resource. Meant to be overloaded.
func load(resource: AbilityGraphNodeResource):
	name = resource.title
	position_offset = resource.position_offset


## Called when the option button is selected.
func _on_option_button_item_selected(_index: int) -> void:
	pass # Replace with function body.
