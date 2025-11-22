extends GraphNode
class_name GraphNodeBase
## Base class for a GraphNode in an AbilityGraph.

@export var animation_player : AnimationPlayer ## The animation player for this node.
var entity : Entity ## The Entity this AbilityGraph is for.

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
	pass
