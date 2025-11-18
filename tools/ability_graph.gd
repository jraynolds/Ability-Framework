extends Control
class_name AbilityGraph
## Class for a node graph that describes the Abilities cast by an Entity.

@export var graph_edit : GraphEdit ## The GraphEdit we're working with.

@export var initial_position = Vector2(40,40) ## The initial location where nodes spawn.
var node_index = 0 ## The index of the current node.
@export var node_option_dropdown : OptionButton ## The options for our add_node_dropdown.
@export var add_node_dropdown : Button ## The button to add a node, chosen by our node_option_dropdown.
@export var node_options : Array[PackedScene]

## Triggered when a graph node makes a connection request.
func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)

## Triggered when a graph node makes a disconnection request.
func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)

## Adds a node to the graph based on the add_button_option selected. 
func _on_add_node_button_pressed() -> void:
	if node_option_dropdown.selected < 0:
		return
	var node = node_options[node_option_dropdown.selected].instantiate() as GraphNodeBase
	node.position_offset += initial_position + (node_index * Vector2(20,20))
	graph_edit.add_child(node)
	node_index += 1
