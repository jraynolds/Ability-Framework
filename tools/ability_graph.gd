extends Control
class_name AbilityGraph
## Class for a node graph that describes the Abilities cast by an Entity.

@export var graph_edit : GraphEdit ## The GraphEdit we're working with.
var graph_nodes : Array[GraphNodeBase] : ## The GraphEdit's nodes.
	get :
		var out : Array[GraphNodeBase] = []
		for graph_child in graph_edit.get_children():
			var graph_node = graph_child as GraphNodeBase
			if graph_node:
				out.append(graph_node)
		return out
var node_selected : GraphNodeBase ## The node that's currently selected.
var enter_node : EnterGraphNode ## The entry node for this graph.

@export var initial_position = Vector2(40,40) ## The initial location where nodes spawn.
var node_index = 0 ## The index of the current node.
@export var node_option_dropdown : OptionButton ## The options for our add_node_dropdown.
@export var add_node_dropdown : Button ## The button to add a node, chosen by our node_option_dropdown.
var node_options : Array[PackedScene] : ## An Array of PackedScenes, for the dropdown.
	get :
		return [ io_node_scene, conditional_node_scene, ability_node_scene, priority_node_scene ]

@export var enter_node_scene : PackedScene ## The PackedScene version of an entry node.
@export var io_node_scene : PackedScene ## The PackedScene version of an input/output node.
@export var conditional_node_scene : PackedScene ## The PackedScene version of a conditional node.
@export var ability_node_scene : PackedScene ## The PackedScene version of an ability node.
@export var priority_node_scene : PackedScene ## The PackedScene version of a priority node.

@export var battle : Battle ## The Battle we're part of.
## The GraphNode the AI brain is currently in. Changing this changes the animation for the active node.
var ai_node_active : GraphNodeBase :
	set(val):
		var prev_node = ai_node_active
		ai_node_active = val
		DebugManager.debug_log(
			"New AI node in the graph is active: " + val.name + ", was previously " +
			(prev_node.name if prev_node else "nothing")
		, self)
		if prev_node:
			prev_node.active = false
		if ai_node_active:
			ai_node_active.active = true
			if ai_node_active == enter_node:
				for node in graph_nodes:
					node.modulate = Color.WHITE
var entity : Entity : ## The entity whose AI we're watching. Changing this loads the graph file.
	set(val):
		entity = val
		init_graph(val.resource.ability_graph)

## Called when this enters the scene.
func _ready() -> void:
	#graph_edit.add_valid_left_disconnect_type(0)
	graph_edit.add_valid_right_disconnect_type(0)


## Loads the graph from a given Resource.
func init_graph(graph_data: AbilityGraphResource):
	clear_graph()
	if !graph_data:
		print("No graph data.")
		return
	for node_resource : AbilityGraphNodeResource in graph_data.nodes:
		var instantiated_node : GraphNodeBase = null
		if node_resource.title.contains("EnterGraphNode"):
			instantiated_node = enter_node_scene.instantiate() as EnterGraphNode
			enter_node = instantiated_node
		elif node_resource.title.contains("IOGraphNode"):
			instantiated_node = io_node_scene.instantiate() as IOGraphNode
		elif node_resource.title.contains("ConditionalGraphNode"):
			instantiated_node = conditional_node_scene.instantiate() as ConditionalGraphNode
		elif node_resource.title.contains("AbilityGraphNode"):
			instantiated_node = ability_node_scene.instantiate() as AbilityGraphNode
		elif node_resource.title.contains("PriorityGraphNode"):
			instantiated_node = priority_node_scene.instantiate() as PriorityGraphNode
		#assert(scene, "No matching PackedScene!")
		if !instantiated_node:
			continue
		instantiated_node.load(node_resource)
		instantiated_node.on_proceed.connect(func(port: int): _on_node_proceed(instantiated_node, port))
		instantiated_node.set_entity(entity)
		graph_edit.add_child(instantiated_node)
	if !enter_node:
		enter_node = enter_node_scene.instantiate()
		graph_edit.add_child(enter_node)
		enter_node.name = "EnterGraphNode"
		enter_node.position_offset = Vector2(40,40)
	for connection in graph_data.connections:
		graph_edit.connect_node(
			connection.from_node, 
			connection.from_port, 
			connection.to_node, 
			connection.to_port
		)
	ai_node_active = enter_node


## Clears the graph.
func clear_graph():
	graph_edit.clear_connections()
	for node in graph_nodes:
		node.queue_free()
	enter_node = null


## Called when there's unconsumed key input.
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Delete node or item"):
		DebugManager.debug_log(
			"Registering the delete keypress"
		, self)
		DebugManager.debug_log(
			"Deleting the selected node, " + (node_selected.name as String if node_selected else "null")
		, self)
		node_selected.queue_free()
	else :
		get_tree().root.push_input(event)


## Returns a GraphNodeBase from its name.
func get_node_from_name(node_name: StringName) -> GraphNodeBase:
	for node in graph_edit.get_children():
		if node.name == node_name:
			return node
	return null


## Returns the GraphEdit's connections to other nodes, from a given GraphNodeBase.
func get_connections_from_node(node: GraphNodeBase) -> Array[Dictionary]:
	var connections : Array[Dictionary] = []
	for connection in graph_edit.connections:
		if connection.from_node == node.name:
			connections.append(connection)
	return connections


## Returns the GraphNodeBases connected to the given port of the given GraphNodeBase.
func get_nodes_connected_at_port(node: GraphNodeBase, port: int) -> Array[GraphNodeBase]:
	var nodes : Array[GraphNodeBase] = []
	#print(node.name)
	#print(port)
	for connection in get_connections_from_node(node):
		#print(connection)
		if connection.from_port == port:
			#print(get_node_from_name(connection.to_node))
			nodes.append(get_node_from_name(connection.to_node))
	return nodes


## Triggered when a graph node makes a connection request.
func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	for connection in get_connections_from_node(get_node_from_name(from_node)):
		if connection.from_port == from_port:
			return
	graph_edit.connect_node(from_node, from_port, to_node, to_port)


## Triggered when a graph node makes a disconnection request.
func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)


## Adds a node to the graph based on the add_button_option selected. 
func _on_add_node_button_pressed() -> void:
	if node_option_dropdown.selected < 0:
		return
	var node = node_options[node_option_dropdown.selected].instantiate()
	var typed_node = node
	#var typed_node = null
	#match node_option_dropdown.selected:
		#0:
			#typed_node = node as IOGraphNode
		#1:
			#typed_node = node as ConditionalGraphNode
		#2:
			#typed_node = node as AbilityGraphNode
		#3:
			#typed_node = node as PriorityGraphNode
	typed_node.position_offset += initial_position + (node_index * Vector2(20,20))
	graph_edit.add_child(typed_node, true)
	typed_node.on_proceed.connect(func(port: int): _on_node_proceed(typed_node, port))
	typed_node.set_entity(entity)
	node_index += 1


## Called when a node is selected.
func _on_graph_edit_node_selected(node: Node) -> void:
	node_selected = node


## Called when a node is deselected.
func _on_graph_edit_node_deselected(_node: Node) -> void:
	node_selected = null


## Called when the battle begins.
func _on_battle_started():
	pass


## Called when the battle advances a tick.
func _on_battle_tick(delta: float) -> void:
	if ai_node_active:
		ai_node_active.tick(delta)


## Called when the battle pauses.
func _on_battle_paused() -> void:
	ai_node_active.animation_player.pause()


## Called when the battle resumes.
func _on_battle_resumed() -> void:
	ai_node_active.animation_player.play()


## Called when a node is ready to proceed along its connections.
func _on_node_proceed(node: GraphNodeBase, port: int) -> void:
	DebugManager.debug_log(
		"Node " + node.name + " attempting to proceed along port " + str(port)
	, self)
	var nodes = get_nodes_connected_at_port(node, port)
	if nodes.is_empty():
		DebugManager.debug_log(
			"Node " + node.name + " was proceeding along port " + str(port) +
			" but found no connections. Returning to the start"
		, self)
		ai_node_active = enter_node
	else :
		DebugManager.debug_log(
			"Node " + node.name + " is proceeding along port " + str(port) +
			" to " + nodes[0].name
		, self)
		ai_node_active = nodes[0]


## Loads a saved AbilityGraphNodeResource into this graph.
func load_data(file_name):
	if ResourceLoader.exists(file_name):
		var graph_data = ResourceLoader.load(file_name)
		if graph_data is AbilityGraphResource:
			init_graph(graph_data)
		else:
			assert(false, "Couldn't load that Graph!")
			pass
	else:
		assert(false, "Couldn't find that Graph's file!")
		pass


## Called when the save button is pressed.
func _on_save_pressed(file_name: String="res://data/entities/" + entity.title + "_graph") -> void:
	file_name += ".tres"
	
	var graph_data = AbilityGraphResource.new()
	graph_data.connections = graph_edit.connections
	for node in graph_edit.get_children():
		if node is GraphNodeBase:
			var node_data = AbilityGraphNodeResource.new()
			node.save(node_data)
			graph_data.nodes.append(node_data)
	if ResourceSaver.save(graph_data, file_name) == OK:
		print("saved")
	else:
		print("Error saving graph_data")
