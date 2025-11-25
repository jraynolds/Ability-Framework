extends Resource
## A Resource representing a trigger. Not meant to be mutated in runtime.
class_name TriggerResource

@export var title : String ## The title of this Trigger.
@export_multiline var description : String ## The description for this Trigger.
enum Trigger {
	OnThisAbilityCast = 0, ## When the associated Ability is cast
	OnRegistered = 10, ## When the Effect is successfully registered on its triggers
	OnGetStatValue = 20, ## When anything retrieves the target's stats.
	OnTakeDamage = 60, ## When the target suffers at least 0 damage.
	#OnAddedAsStatus = 10, ## When the Effect is added as a status Effect
}
## The type of Trigger. By default, when the associated Ability is cast.
@export var trigger : Trigger = Trigger.OnThisAbilityCast 


## Adds a listener to the appropriate game trigger for the given Ability, calling the given function.
## For this to work properly, we're expecting the function to need, as its final parameters, caster: Entity and targets: Array[Entity].
## Whatever Signal gets bound needs to emit 0 variables--if it emits more, we untangle its parameters to put caster and targets last.
func register(ability: Ability, caster: Entity, targets: Array[Entity], function: Callable):
	match trigger :
		Trigger.OnThisAbilityCast:
			#ability.on_cast.connect(function.bind(caster, targets))
			ability.on_cast.connect(function)
		Trigger.OnRegistered:
			#effect.on_registered.connect(function.bind(caster, targets))
			ability.on_cast.connect(function)
		Trigger.OnGetStatValue:
			pass ## Not used to connect listeners; instead, EntityStatusComponent and EntityStatsComponent look for this.
		Trigger.OnTakeDamage:
			### Frankly, it sucks that this is how we have to do it in Godot
			var bound_arguments = function.get_bound_arguments()
			function = Callable(function.get_object(), function.get_method())
			#var params = function.get_bound_arguments()
			bound_arguments.append(caster)
			bound_arguments.append(targets)
			function = function.bindv(bound_arguments)
			#params = function.get_bound_arguments()
			function = function.unbind(3) ## Ignores the first 3 non-bind arguments passed to the function: here, the three from OnTakeDamage.
			for target in targets:
				target.stats_component.on_take_damage.connect(function)
		#Trigger.OnAddedAsStatus:
			#for target in targets:
				#target.statuses_component.on_status_added.connect(func(status: Effect):
					##print(status)
					#if status == effect:
						##print("matches!")
						#function.bind(caster, targets)
				#)


## Removes a listener from the appropriate game trigger for the given Effect.
func unregister(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity], function: Callable):
	match trigger :
		Trigger.OnThisAbilityCast:
			ability.on_cast.disconnect(function.bind(caster, targets))
		Trigger.OnRegistered:
			effect.on_registered.disconnect(function.bind(caster, targets))
		Trigger.OnGetStatValue:
			pass ## Not used to connect listeners; instead, EntityStatusComponent and EntityStatsComponent look for this.
		Trigger.OnTakeDamage:
			## Frankly, it sucks that this is how we have to do it in Godot
			var bound_arguments = function.get_bound_arguments()
			function = Callable(function.get_object(), function.get_method())
			#var params = function.get_bound_arguments()
			bound_arguments.append(caster)
			bound_arguments.append(targets)
			function = function.bindv(bound_arguments)
			#params = function.get_bound_arguments()
			function = function.unbind(3) ## Ignores the first 3 non-bind arguments passed to the function: here, the three from OnTakeDamage.
			for target in targets:
				target.stats_component.on_take_damage.disconnect(function)
		#Trigger.OnAddedAsStatus:
			#for target in targets:
				#target.statuses_component.on_status_added.disconnect(func(status: Effect):
					#if status == effect:
						#function.bind(caster, targets)
				#)
