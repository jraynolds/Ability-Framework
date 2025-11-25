extends GraphNodeBase
class_name AbilityGraphNode
## A node in the AbilityGraph that holds a single Ability castable by an Entity.

var resources : Array[AbilityResource] ## The AbilityResources available to us.
var ability_resource : AbilityResource : ## The AbilityResource we choose.
	get :
		if option_button.selected > -1:
			return resources[option_button.selected]
		return null
var ability : Ability : ## Our Ability on our Entity, as an actual Ability.
	get :
		return entity.abilities_component.get_ability_by_resource(ability_resource)
var resource_path_to_load : String ## The resource we're waiting to load, if any.

## Called when the node enters the scene.
func _ready() -> void:
	super()
	set_slot(1, false, 0, Color.PURPLE, true, 0, Color.GREEN) ## On casted
	set_slot(2, false, 0, Color.PURPLE, true, 0, Color.YELLOW) ## On canceled
	set_slot(3, false, 0, Color.PURPLE, true, 0, Color.ORANGE) ## On interrupted
	set_slot(4, false, 0, Color.PURPLE, true, 0, Color.RED) ## Unable to cast (for a reason besides GCD)

	for file_path in get_all_file_paths("res://data/"):
		if file_path.ends_with(".tres"):
			var resource = ResourceLoader.load(file_path) as AbilityResource
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


## Initializes much of our setup.
func set_entity(e: Entity):
	if entity:
		entity.abilities_component.on_ability_cast.disconnect(_on_cast)
		entity.abilities_component.on_ability_cast_interrupted.disconnect(_on_cast_interrupted)
	super(e)
	if entity:
		entity.abilities_component.on_ability_cast.connect(_on_cast)
		entity.abilities_component.on_ability_cast_interrupted.connect(_on_cast_interrupted)


## Called when the battle proceeds to the next frame. Proceeds through the AI's brain and tries to cast this Ability.
func tick(_delta: float):
	if entity.abilities_component.ability_casting :
		return
	elif ability._gcd_type == AbilityResource.GCD.OnGCD and entity.abilities_component.gcd_remaining > 0.0:
		return
	elif !entity.abilities_component.can_cast_at(ability, entity.targeting_component.targets):
		modulate = Color.RED
		on_proceed.emit(4)
	else :
		entity.abilities_component.cast(ability, entity.targeting_component.targets)


## Called when our Entity casts an Ability. Ignored if it's not ours.
func _on_cast(cast_ability: Ability, _targets: Array[Entity]):
	if cast_ability != ability:
		return
	modulate = Color.GREEN
	on_proceed.emit(1)


## Called when our Entity's Ability is interrupted. Ignored if it's not ours.
func _on_cast_interrupted(cast_ability: Ability, _targets: Array[Entity], interrupter: Entity):
	if cast_ability != ability:
		return
	
	if interrupter == entity:
		modulate = Color.YELLOW
		on_proceed.emit(2)
	else:
		modulate = Color.ORANGE
		on_proceed.emit(3)


## Called to save this node into the given Resource for later retrieval.
func save(resource: AbilityGraphNodeResource):
	super(resource)
	var resource_path = ability_resource.resource_path
	resource.node_data.ability_resource_path = resource_path


## Called to load into this node with the given resource.
func load(resource: AbilityGraphNodeResource):
	super(resource)
	resource_path_to_load = resource.node_data.ability_resource_path
