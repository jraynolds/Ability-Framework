extends Resource
## A Resource representing a trigger. Not meant to be mutated in runtime.
class_name TriggerResource

@export var title : String ## The title of this Trigger.
@export_multiline var description : String ## The description for this Trigger.
enum Trigger {
	OnThisAbilityCast = 0, ## When the associated Ability is cast
	OnRegistered = 10, ## When the Effect is successfully registered on its triggers
	OnGetStatValue = 20, ## When anything retrieves the target's stats.
	OnGetKeywordValue = 21, ## When anything retrieves the target's keywords.
	OnTakeDamage = 60, ## When the target suffers at least 0 damage.
	OnTick = 80, ## When the game advances 1 frame.
	OnBattleTick = 81, ## When the battle advances 1 frame.
	OnChannelTick = 84, ## When the Ability has been channeling for 1 frame.
	#OnAddedAsStatus = 10, ## When the Effect is added as a status Effect
}
## The type of Trigger. By default, when the associated Ability is cast.
@export var trigger : Trigger = Trigger.OnThisAbilityCast
@export var cooldown : ValueResource ## The optional minimum duration in seconds between each activation of this trigger.

## Adds a listener to the appropriate game trigger for the given Ability, calling the given function.
## For this to work properly, we're expecting the function to need, as its final parameters, caster: Entity and targets: Array[Entity].
## Whatever Signal gets bound needs to emit 0 variables--if it emits more, we untangle its parameters to put caster and targets last.
func register(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity], function: Callable):
	var num_unbind_params = get_parameters_to_unbind(trigger)
	for s in get_signals_to_bind(trigger, effect, ability, caster, targets):
		if !num_unbind_params:
			s.connect(function.bind(self))
		else :
			s.connect(
				function
					.bind(self)
					.unbind(num_unbind_params)
			)


### Calls the given callable, if the given Effect has been running for enough time.
#func call_if_cooldown_exceeded(effect: Effect, _ability: Ability, caster: Entity, targets: Array[Entity], function: Callable):
	#DebugManager.debug_log(
		#"The trigger " + resource_path + " is attempting to call effect " + effect.name
	#, self)
	#if !cooldown:
		#function.call(caster, targets, self)
	#elif cooldown.get_value(caster, targets) < effect.time_since_last_trigger[self]:
		#function.call(caster, targets, self)
	#DebugManager.debug_log(
		#"The trigger " + resource_path + " attempted to call effect " + effect.name +
		#" but our cooldown time of " + str(cooldown.get_value(caster, targets)) + 
		#" is greater than the duration since it was triggered by us, " + str(effect.time_since_last_trigger[self])
	#, self)


## Removes a listener from the appropriate game trigger for the given Effect.
func unregister(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity], function: Callable):
	var num_unbind_params = get_parameters_to_unbind(trigger)
	for s in get_signals_to_bind(trigger, effect, ability, caster, targets):
		if !num_unbind_params:
			s.disconnect(function)
		else :
			s.disconnect(
				function
					.unbind(num_unbind_params)
			)


## Returns an Array of Signals that correspond to the given Trigger and the given parameters.
func get_signals_to_bind(
	trigger_type: Trigger, 
	_effect: Effect, 
	ability: Ability, 
	_caster: Entity, 
	targets: Array[Entity]
) -> Array[Signal]:
	match trigger_type :
		Trigger.OnThisAbilityCast:
			return [ability.on_cast]
		Trigger.OnRegistered:
			return [ability.on_registered]
		Trigger.OnGetStatValue:
			return [] ## Not used to connect listeners; instead, EntityStatusComponent and EntityStatsComponent look for this.
		Trigger.OnTakeDamage:
			var signals = []
			for target in targets:
				signals.append(target.stats_component.on_take_damage)
			return signals
		Trigger.OnTick:
			return [] ##TODO
		Trigger.OnBattleTick:
			return [GameManager.battle.on_tick]
		Trigger.OnChannelTick:
			return [ability.on_channel_tick]
	return []


## Returns how many parameters must be unbound from the signals matching the given Trigger to match our needs.
func get_parameters_to_unbind(trigger_type: Trigger) -> int:
	match trigger_type :
		Trigger.OnThisAbilityCast:
			return 0
		Trigger.OnRegistered:
			return 0
		Trigger.OnGetStatValue:
			return 0 ## Not used to connect listeners; instead, EntityStatusComponent and EntityStatsComponent look for this.
		Trigger.OnTakeDamage:
			return 0
		Trigger.OnTick:
			return 0 ##TODO
		Trigger.OnBattleTick:
			return 3
		Trigger.OnChannelTick:
			return 1
	return 0
