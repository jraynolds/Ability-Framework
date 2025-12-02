extends GraphNodeBase
class_name EnterGraphNode
## Entry for the graph.

## Called when this node enters the scene.
func _ready() -> void:
	add_slot(false, true, Color.PURPLE)
