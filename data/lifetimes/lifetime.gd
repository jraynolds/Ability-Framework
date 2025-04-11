extends Node
## The runtime instance of a LifetimeResource.
class_name Lifetime

var _resource : LifetimeResource ## The base LifetimeResource this Lifetime represents.
var _title : String ## The title of this Lifetime.
var _description : String ## The description of this Lifetime.
var _duration : float ## The duration the associated Effect has been active. Compared with the LifetimeResource.
var _triggers : int ## The times the associated Effect has been triggered. Compared with the LifetimeResource.

signal on_lifetime_expired ## emitted when the duration has exceeded the lifespan, or the number of triggers has.

## Returns an instance of this initialized with the given LifetimeResource.
func from_resource(resource: LifetimeResource) -> Lifetime:
	_resource = resource
	_title = resource.title
	_description = resource.description
	return self


## Called when the associated Effect is triggered. 
## Increases the trigger amount and emits on_lifetime_expired if it's more than the LifetimeResource's triggers.
func on_effect_triggered(caster: Entity, targets: Array[Entity]):
	_triggers += 1
	if _resource.is_lifetime_expired(caster, targets, 0, _triggers):
		on_lifetime_expired.emit()


## Called when the game ticks.
## Increases the duration and emits on_lifetime_expired if it's longer than the LifetimeResource's duration.
func on_game_tick(caster: Entity, targets: Array[Entity], delta: float):
	_duration += delta
	if _resource.is_lifetime_expired(caster, targets, _duration, 0):
		on_lifetime_expired.emit()
