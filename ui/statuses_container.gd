extends HBoxContainer
## UI container for an Entity's Statuses.
class_name StatusesContainer

## The status type, good bad or neutral, that this container displays.
@export var status_positivity : Math.Positivity = Math.Positivity.Positive

@export var status_container_scene : PackedScene ## The default Status container object.
var entity : Entity : ## The Entity whose statuses we're representing. Changing this connects us to its signals.
	set(val):
		var old_val = entity
		entity = val
		if old_val:
			old_val.statuses_component.on_status_added.disconnect(_on_status_added)
			old_val.statuses_component.on_status_removed.disconnect(_on_status_removed)
		if entity:
			entity.statuses_component.on_status_added.connect(_on_status_added)
			entity.statuses_component.on_status_removed.connect(_on_status_removed)
## The Statuses we're representing, paired with the container each is in.
var _statuses : Dictionary[Effect, StatusContainer] = {}


## Called every frame.
func _process(delta: float) -> void:
	if !entity:
		return
	var statuses = entity.statuses_component.get_statuses(status_positivity)
	var same_arrays = true
	for status in statuses:
		if status not in _statuses.keys():
			same_arrays = false
	if !same_arrays:
		for status in _statuses:
			_on_status_removed(status)
		_statuses = {}
		for status in statuses:
			_on_status_added(status)
	for status in _statuses:
		_statuses[status].set_stacks(entity.statuses_component.get_effect_stacks(status))


## Called when the connected statuses component adds a status.
func _on_status_added(status: Effect):
	if status._positivity != status_positivity:
		return
	var status_container : StatusContainer = status_container_scene.instantiate().from_status(status)
	add_child(status_container)
	_statuses[status] = status_container


## Called when the connected statuses component adds a status.
func _on_status_removed(status: Effect):
	if status._positivity != status_positivity:
		return
	assert(_statuses.has(status), "But we don't have that status Effect!")
	_statuses[status].queue_free()
	_statuses.erase(status)
