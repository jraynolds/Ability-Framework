extends GraphNodeBase
class_name AbilityGraphNode
## A node in the AbilityGraph that holds a single Ability castable by an Entity.

@export var option_button : OptionButton ## The dropdown menu for the Ability we offer.

## Called when the node enters the scene.
func _ready() -> void:
	super()
	set_slot(1, false, 0, Color.PURPLE, true, 0, Color.GREEN)
	set_slot(2, false, 0, Color.PURPLE, true, 0, Color.RED)

	for file_path in get_all_file_paths("res://data/conditionals"):
		if file_path.ends_with(".tres"):
			var resource = ResourceLoader.load(file_path)
			option_button.add_item(resource.resource_path.split("/")[-1])
