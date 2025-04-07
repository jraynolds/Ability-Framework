extends ValueResource
## A ValueResource gathered from the target Entity's history of damage received.
class_name DamagedHistoryValueResource

@export var target : Targeting.Target ## What Entity we should be checking.
## How many damage instances back we should look. Must be a positive number. By default, 0.
@export var index : ValueResource 
@export var return_type : ReturnType ## What kind of value we want to return. By default, actual damage taken.
enum ReturnType {
	DamageTaken, ## The actual amount subtracted from HP
	DamageAssigned, ## The damage amount before any modifiers
	DamageType ## The type of damage dealt; references DamageEffectResource.DamageType
}

## Finds the damage history at the given index and, if present, returns the type of value specified.
## If no history can be found, returns NAN.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	var index_value = index.get_value(caster, targets) if index else 0
	assert(index_value >= 0, "Index must be a positive number!")
	var entity = caster
	if target == Targeting.Target.Target:
		entity = targets[0]
	elif target == Targeting.Target.Targets:
		assert(false, "No plan for multiple targets.")
	assert(entity != null, "No entity to check damage history for!")
	var damage_history = entity.history_component.get_damage_history(index_value)
	if !damage_history:
		return NAN
	match return_type:
		ReturnType.DamageTaken:
			return damage_history.damage_taken
		ReturnType.DamageAssigned:
			return damage_history.damage_assigned
		ReturnType.DamageType:
			return damage_history.damage_type
	assert(false, "How did we get here?")
	return NAN
