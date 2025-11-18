extends GraphNodeBase
class_name ConditionalGraphNode
## A graph node in the AbilityGraph that directs one way if it evaluates to true, another if false.

@export var option_button : OptionButton ## The dropdown menu for the conditional we offer.

## Called when the nodee enters the scene for the first time.
func _ready() -> void:
	super()
	set_slot(1, false, 0, Color.PURPLE, true, 0, Color.GREEN)
	set_slot(2, false, 0, Color.PURPLE, true, 0, Color.RED)
	
	for file_path in get_all_file_paths("res://data/conditionals"):
		if file_path.ends_with(".tres"):
			var resource = ResourceLoader.load(file_path)
			option_button.add_item(resource.resource_path.split("/")[-1])
