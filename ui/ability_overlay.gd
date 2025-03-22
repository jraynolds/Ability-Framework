extends Control
## A UI element that displays the player's ability bars.
class_name AbilityOverlay

@export var ability_slots : Array[AbilitySlot] ## The ability slots on the hotbar, beginning with the bottom row.

signal on_ability_cast(caster: Entity, ability: Ability) ## Emitted when the player activates a valid ability.

var entity : Entity : ## The player entity. When this is modified, updates our slots.
	set(val):
		entity = val
		for ability in entity.abilities_component.abilities.keys():
			ability_slots[entity.abilities_component.abilities[ability]].button.ability = ability


## Called when this node becomes active. Connects signals from all slots.
func _ready() -> void:
	for ability_slot in ability_slots:
		ability_slot.on_activated.connect(func(): on_slot_activated(ability_slot))


## Called when a slot is activated.
func on_slot_activated(slot: AbilitySlot):
	if slot.button.ability:
		on_ability_cast.emit(entity, slot.button.ability)
