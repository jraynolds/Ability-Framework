extends ValueResource
## ValueResource that returns information about the history of damage dealt to a target.
## Tracks backwards the given number of changes.
class_name DamagedHistoryValueResource

## An optional targeting resource to use for this value getter. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var index_resource : ValueResource ## How many changes back we look. By default, none.
## What we want to return. By default, damage taken.
@export var returned_information : HistoryEntityComponent.DamageHistoryInfo = HistoryEntityComponent.DamageHistoryInfo.DamageTaken

## Returns the magnitude of the target's previous stat change.
func calc_value(effect_info: EffectInfo, overrides: Dictionary={}):
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
		
	var index = index_resource.get_value(effect_info) if index_resource else 0.0
	
	var damage = targets[0].history_component.get_damage_history(index)
	if !damage:
		return NAN
	match returned_information:
		HistoryEntityComponent.DamageHistoryInfo.DamageTaken:
			return damage.damage_taken
		HistoryEntityComponent.DamageHistoryInfo.DamageAssigned:
			return damage.damage_taken
		HistoryEntityComponent.DamageHistoryInfo.DamageMitigated:
			if damage.damage_taken == NAN or damage.damage_assigned == NAN:
				return NAN
			return damage.damage_assigned - damage.damage_taken
		HistoryEntityComponent.DamageHistoryInfo.DamageType:
			return damage.damage_type
