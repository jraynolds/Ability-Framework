extends ValueResource
## ValueResource that returns information about the history of damage dealt to a target.
## Tracks backwards the given number of changes.
class_name DamagedHistoryValueResource

@export var target_resource : ValueResource ## What Entity we should be checking. By default, the caster.
@export var index_resource : ValueResource ## How many changes back we look. By default, none.
## What we want to return. By default, damage taken.
@export var returned_information : HistoryEntityComponent.DamageHistoryInfo = HistoryEntityComponent.DamageHistoryInfo.DamageTaken

## Returns the magnitude of the target's previous stat change.
func get_value(caster: Entity, targets: Array[Entity]):
	var target = target_resource.get_value(caster, targets) if target_resource else Targeting.Target.Caster
	var index = index_resource.get_value(caster, targets) if index_resource else 0
	
	var entity = caster
	if target == Targeting.Target.Target:
		entity = targets[0]
	elif target == Targeting.Target.Targets:
		assert(false, "No plan for multiple targets.")
	assert(entity != null, "No entity to check stat changes for!")
	
	var damage = entity.history_component.get_damage_history(index)
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
