extends Node
## A class for outputting custom debug messages. Autoloaded.
class_name DebugManagerGlobal

## Whether debugging should be output for Abilities.
@export var abilities : bool

## Whether debugging should be output for Effects.
@export var effects : bool
## Whether debugging should be output for StatusEffects.
@export var status_effects : bool

## Whether debugging should be output for StatsEntityComponents.
@export var stats_entity_components : bool
## Whether debugging should be output for AbilitiesEntityComponents
@export var abilities_entity_components : bool
## Whether debugging should be output for StatusesEntityComponents.
@export var statuses_entity_components : bool

## Whether debugging should be output for TransformResources.
@export var transform : bool
## Whether debugging should be output for TriggerResources.
@export var trigger_resources : bool
## Whether debugging should be output for StatModifyEffectResources.
@export var stat_modify : bool
## Whether debugging should be output for ExpirationResources.
@export var expiration_resources : bool

## Whether debugging should be output for ConditionalResources.
@export var conditional_resources : bool
## Whether debugging should be output for ValueResources.
@export var value_resources : bool

## Whether debugging should be output for stat changes.
@export var stats : bool

## Whether debugging should be output for StatusesContainers.
@export var statuses_containers : bool
## Whether debugging should be output for AbilityCastBars.
@export var ability_cast_bars : bool

## Outputs a detailed log if the log's source is one2 we're outputting.
func debug_log(message: String, source: Variant):
	if is_instance_of(source, Ability) and abilities:
		print("ABILITY: " + message + ", from '" + source.name + "'")
	
	if is_instance_of(source, Effect):
		if is_instance_of(source, StatusEffect) and status_effects:
			print("STATUSEFFECT: " + message + ", from '" + source.name + "'")
			return
		else:
			print("EFFECT: " + message + ", from '" + source.name + "'")
			return
	
	if is_instance_of(source, EntityComponent):
		if is_instance_of(source, StatsEntityComponent) and stats_entity_components:
			print("ENTITYSTATS: " + message + ", from '" + source.entity.name + "'")
			return
		elif is_instance_of(source, StatusesEntityComponent) and statuses_entity_components:
			print("ENTITYSTATUSES: " + message + ", from '" + source.entity.name + "'")
			return
		elif is_instance_of(source, AbilitiesEntityComponent) and abilities_entity_components:
			print("ENTITYABILITIES: " + message + ", from '" + source.entity.name + "'")
			return
	
	if is_instance_of(source, EffectResource):
		if is_instance_of(source, StatModifyEffectResource) and stat_modify:
			print("STATMODIFYEFFECT: " + message + ", from '" + source.resource_path + "'")
			return
	
	elif is_instance_of(source, TransformResource) and transform:
		print("TRANSFORM: " + message + ", from '" + source.resource_path + "'")
	elif is_instance_of(source, TriggerResource) and trigger_resources:
		print("TRIGGER: " + message + ", from '" + source.resource_path + "'")
	elif is_instance_of(source, ExpirationResource) and expiration_resources:
		print("EXPIRATIONRESOURCE: " + message + ", from '" + source.resource_path + "'")
	
	elif is_instance_of(source, StatusesContainer) and statuses_containers:
		print("STATUSCONTAINER: " + message + ", from '" + source.name + "'")
	elif is_instance_of(source, AbilityCastBar) and ability_cast_bars:
		print("ABILITYCASTBAR: " + message + ", from '" + source.name + "'")
	
	## Conditionals
	elif is_instance_of(source, ConditionalResource) and conditional_resources:
		print("CONDITIONALRESOURCE: " + message + ", from '" + source.resource_path + "'")
	## Values
	elif is_instance_of(source, ValueResource) and value_resources:
		print("VALUERESOURCE: " + message + ", from '" + source.resource_path + "'")
	
	## Stats
	elif is_instance_of(source, Stat) and stats:
		print("STAT: " + message + ", from '" + source._title + "'")
