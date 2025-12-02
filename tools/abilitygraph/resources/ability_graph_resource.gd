extends Resource
class_name AbilityGraphResource
## Class for saving info in an AbilityGraph GraphEdit.

## The connections between nodes, in the following form:
## { from_node: StringName, from_port: int, to_node: StringName, to_port: int }
@export var connections: Array[Dictionary]
@export var nodes: Array[AbilityGraphNodeResource]
