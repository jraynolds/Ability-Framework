extends EntityComponent
class_name TargetingEntityComponent
## Class for an Entity's targeting logic.

var targets : Array[Entity] ## The current target(s) for this Entity.
var _targetable : bool ## Whether this Entity is currently targetable by Effects.


## Overloaded method for logic that happens when the Entity's resource is changed.
## Sets _targetable to true.
func load_entity_resource(_resource: EntityResource):
	_targetable = true


## Returns whether this Entity is targetable.
func is_targetable():
	var targetable = _targetable
	for effect in entity.statuses_component.statuses:
		## Skip any Effects without OnGetKeywordValue triggers.
		if !effect._triggers.any(func(trigger: TriggerResource): 
			return trigger.trigger == TriggerResource.Trigger.OnGetKeywordValue
		):
			continue
		## Skip any Effects without KeywordModifyEffectResource.
		var keyword_resource = effect._resource as KeywordModifyEffectResource
		if !keyword_resource:
			continue
		## Skip any KeywordModifyEffectResource without this keyword as the one it modifies.
		if keyword_resource.keyword != KeywordModifyEffectResource.Keyword.Targetable:
			continue
		for i in range(entity.statuses_component.status_stacks[effect]):
			targetable = keyword_resource.get_modified_value(
				targetable, 
				effect._ability._caster,
				[entity]
			)
	return targetable
