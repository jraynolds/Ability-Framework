extends GraphNodeBase
class_name AbilityGraphNode
## A node in the AbilityGraph that holds a single Ability castable by an Entity.

@export var option_button : OptionButton ## The dropdown menu for the AbilityResource we offer.
var resources : Array[AbilityResource] ## The AbilityResources available to us.
var ability_resource : AbilityResource : ## The AbilityResource we choose.
	get :
		if option_button.selected > -1:
			return resources[option_button.selected]
		return null
var ability : Ability : ## Our Ability on our Entity, as an actual Ability.
	get :
		return entity.abilities_component.get_ability_by_resource(ability_resource)

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
func tick(delta: float):
	super(delta)
	if ability._gcd_type == AbilityResource.GCD.OnGCD and entity.abilities_component.gcd_remaining > 0.0:
		return
	if !entity.abilities_component.can_cast_at(ability, entity.targeting_component.targets):
		on_proceed.emit(4)


## Called when our Entity casts an Ability. Ignored if it's not ours.
func _on_cast(cast_ability: Ability, targets: Array[Entity]):
	if cast_ability != ability:
		return
	on_proceed.emit(1)


## Called when our Entity's Ability is interrupted. Ignored if it's not ours.
func _on_cast_interrupted(cast_ability: Ability, targets: Array[Entity], interrupter: Entity):
	if cast_ability != ability:
		return
	
	if interrupter == entity:
		on_proceed.emit(2)
	else:
		on_proceed.emit(3)
