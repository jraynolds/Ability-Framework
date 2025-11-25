extends GraphNodeBase
class_name ConditionalGraphNode
## A graph node in the AbilityGraph that directs one way if it evaluates to true, another if false.

var resources : Array[ConditionalResource] ## The ConditionalResources available to us.
var conditional_resource : ConditionalResource : ## The ConditionalResource we choose.
	get :
		if option_button.selected > -1:
			return resources[option_button.selected]
		return null
#@export var subconditional_options_1 : OptionButton ## The optional dropdown menu for the sub-conditionals our main one may need.
#@export var subconditional_options_2 : OptionButton ## The 2nd optional dropdown menu for the sub-conditionals our main one may need. 
var resource_path_to_load : String ## The resource we're waiting to load, if any.

## Called when the nodee enters the scene for the first time.
func _ready() -> void:
	super()
	set_slot(1, false, 0, Color.PURPLE, true, 0, Color.GREEN)
	set_slot(2, false, 0, Color.PURPLE, true, 0, Color.RED)

	for file_path in get_all_file_paths("res://data/"):
		if file_path.ends_with(".tres"):
			var resource = ResourceLoader.load(file_path) as ConditionalResource
			if resource:
				resources.append(resource)
	for resource in resources:
		option_button.add_item(resource.resource_path.split("/")[-1])
	if resource_path_to_load:
		var ability_resource_index = -1
		for i in range(len(resources)):
			if resources[i].resource_path == resource_path_to_load:
				ability_resource_index = i
		option_button.select(ability_resource_index)
		resource_path_to_load = ""


## Called when the battle proceeds to the next frame. Proceeds through the AI's brain. Meant to be overloaded.
func tick(_delta: float):
	var eval = conditional_resource.is_met(null, null, entity, entity.targeting_component.targets)
	if eval:
		on_proceed.emit(0)
		modulate = Color.GREEN
	else :
		on_proceed.emit(1)
		modulate = Color.RED


## Called to save this node into the given Resource for later retrieval.
func save(resource: AbilityGraphNodeResource):
	super(resource)
	var resource_path = conditional_resource.resource_path
	resource.node_data.conditional_resource_path = resource_path


## Called to load into this node with the given resource.
func load(resource: AbilityGraphNodeResource):
	super(resource)
	resource_path_to_load = resource.node_data.conditional_resource_path
