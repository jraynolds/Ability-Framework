extends ValueResource
## A ValueResource that returns the int value of a DamageType enum found on a Status.
class_name StatusDamageTypeValueResource

@export var target : Targeting.Target ## What Entity we should be checking.
@export var status : EffectResource ## The Status we're checking DamageType for.

## Returns the int value of the DamageType enum on the given target's StatusEffect.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	var entity = caster
	if target == Targeting.Target.Target:
		entity = targets[0]
	elif target == Targeting.Target.Targets:
		assert(false, "No plan for multiple targets.")
	assert(entity != null, "No entity to check statuses for!")
	var status = entity.statuses_component.get_status_by_resource(status)
	if !status:
		return NAN
	var damage_resource = status._resource as DamageEffectResource
	assert(damage_resource, "We found the resource, but it's not a damage resource!")
	return damage_resource.get_damage_type(caster, targets)
