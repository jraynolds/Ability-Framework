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
## For this to work properly, the function's parameters must be ONLY trigger: TriggerResource.
## We unbind everything else.
func register(effect_info: EffectInfo, overrides: Dictionary={}, function: Callable=Callable()):
	var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	#var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
	
	var num_unbind_params = get_parameters_to_unbind(trigger)
	var signals_to_bind = get_signals_to_bind(trigger, effect_info, overrides)
	
	DebugManager.debug_log(
		"Registering an effect named " + effect.name + " to signal type " + Natives.enum_name(Trigger, trigger) + 
		". It has " + str(num_unbind_params) + " params we have to unbind first" 
	, self)
	for s in signals_to_bind:
		if num_unbind_params > 0:
			var fn = function.bindv([self])
			fn = fn.unbind(num_unbind_params)
			s.connect(fn)
		else :
			s.connect(function.bind(self))
		#if !num_unbind_params:
			#s.connect(function.bind(self))
		#else :
			#s.connect(
				#function
					#.bind(self)
					#.unbind(num_unbind_params)
			#)


## Removes a listener from the appropriate game trigger for the given Effect.
func unregister(effect_info: EffectInfo, overrides: Dictionary={}, function: Callable=Callable()):
	var num_unbind_params = get_parameters_to_unbind(trigger)
	for s in get_signals_to_bind(trigger, effect_info, overrides):
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
	effect_info: EffectInfo,
	overrides: Dictionary={}
) -> Array[Signal]:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
	
	match trigger_type :
		Trigger.OnThisAbilityCast:
			return [ability.on_cast]
		Trigger.OnRegistered:
			return [ability.on_registered] ##TODO
		Trigger.OnGetStatValue:
			return [] ## Not used to connect listeners; instead, EntityStatusComponent and EntityStatsComponent look for this.
		Trigger.OnTakeDamage:
			var signals : Array[Signal] = []
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
			return 1
		Trigger.OnRegistered:
			return 1
		Trigger.OnGetStatValue:
			return 0 ## Not used to connect listeners; instead, EntityStatusComponent and EntityStatsComponent look for this.
		Trigger.OnTakeDamage:
			return 4
		Trigger.OnTick:
			return 0 ##TODO
		Trigger.OnBattleTick:
			return 1
		Trigger.OnChannelTick:
			return 2
	return 0
