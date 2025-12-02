extends GraphNodeBase
class_name EnterGraphNode
## Entry for the graph.

## Called when this node enters the scene.
func _ready() -> void:
	set_slot(0, false, 0, Color.PURPLE, true, 0, Color.PURPLE)
