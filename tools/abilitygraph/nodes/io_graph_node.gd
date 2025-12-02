extends GraphNodeBase
class_name IOGraphNode
## GraphNode that supports one entrance and one exit.

## Called when this node enters the scene.
func _ready() -> void:
	add_slot(true, true, Color.PURPLE)
