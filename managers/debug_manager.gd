extends Node
## A class for outputting custom debug messages. Autoloaded.
class_name DebugManagerGlobal

## Whether debugging should be output for Effects.
@export var effect : bool
## Whether debugging should be output for StatsEntityComponents.
@export var stats_entity_component : bool
## Whether debugging should be output for TransformResources.
@export var transform : bool
## Whether debugging should be output for StatModifyEffectResources.
@export var stat_modify : bool

## Outputs a detailed log if the log's source is one2 we're outputting.
func debug_log(message: String, source: Variant):
	if is_instance_of(source, Effect) and effect:
		print("EFFECT: " + message + ", from '" + source.name + "'")
	elif is_instance_of(source, StatsEntityComponent) and stats_entity_component:
		print("ENTITYSTATS: " + message + ", from '" + source.entity.name + "'")
	elif is_instance_of(source, TransformResource) and transform:
		print("TRANSFORM: " + message + ", from '" + source.resource_path + "'")
	elif is_instance_of(source, StatModifyEffectResource) and stat_modify:
		print("STATMODIFYEFFECT: " + message + ", from '" + source.resource_path + "'")
