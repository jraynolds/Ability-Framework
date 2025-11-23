extends GraphNode
class_name GraphNodeBase
## Base class for a GraphNode in an AbilityGraph.

@export var option_button : OptionButton ## The dropdown menu we offer.
@export var animation_player : AnimationPlayer ## The animation player for this node.
var entity : Entity ## The Entity this AbilityGraph is for.
var active : bool : ## Whether the AI brain is on this node.
	set(val):
		active = val
		if val and !animation_player.is_playing():
			animation_player.play("pulsate")
		elif !val:
			animation_player.stop()

signal on_proceed(port: int) ## Emitted when we're ready to proceed along a connection.

## Called when this node enters the scene.
func _ready() -> void:
	set_slot(0, true, 0, Color.PURPLE, false, 0, Color.RED)


## Initializes much of our setup.
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


## Called when the battle proceeds to the next frame. Proceeds through the AI's brain. Meant to be overloaded.
func tick(delta: float):
	on_proceed.emit(0)
	modulate = Color.PURPLE
	#print("I'm active: " + name)


## Called to save this node into the given Resource for later retrieval. Meant to be overloaded.
func save(resource: AbilityGraphNodeResource):
	resource.title = name
	resource.position_offset = position_offset


## Called to load into this node with the given resource. Meant to be overloaded.
func load(resource: AbilityGraphNodeResource):
	name = resource.title
	position_offset = resource.position_offset
