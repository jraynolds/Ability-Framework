extends GraphNodeBase
class_name IOGraphNode
## GraphNode that supports one entrance and one exit.

## Called when this node enters the scene.
func _ready() -> void:
	set_slot(1, true, 0, Color.PURPLE, true, 0, Color.PURPLE)
