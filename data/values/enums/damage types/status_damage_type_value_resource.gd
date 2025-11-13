extends ValueResource
## A ValueResource that returns the int value of a DamageType enum found on a Status.
class_name StatusDamageTypeValueResource

 ## An optional targeting resource to use for this value getter. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var status : EffectResource ## The Status we're checking DamageType for.

## Returns the int value of the DamageType enum on the given target's StatusEffect.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(caster)
	
	var matching_status = targets[0].statuses_component.get_status_by_resource(status)
	if !matching_status:
		return NAN
	var damage_resource = matching_status._resource as DamageEffectResource
	assert(damage_resource, "We found the resource, but it's not a damage resource!")
	var damage_type = damage_resource.get_damage_type(caster, targets)
	return damage_type
