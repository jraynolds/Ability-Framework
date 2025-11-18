extends GraphNode
class_name GraphNodeBase
## Base class for a GraphNode in an AbilityGraph.

## Called when this node enters the scene.
func _ready() -> void:
	set_slot(0, true, 0, Color.PURPLE, false, 0, Color.RED)


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
