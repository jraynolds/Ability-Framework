extends Control
## A UI element that displays the player's ability bars.
class_name AbilityOverlay

@export var ability_slots : Array[AbilitySlot] ## The ability slots on the hotbar, beginning with the bottom row.

signal on_ability_activated(caster: Entity, ability: Ability) ## Emitted when the player activates a valid Ability.

var entity : Entity : ## The player Entity. When this is modified, updates our slots.
	set(val):
		var old_val = entity
		entity = val
		for ability in entity.abilities_component.abilities.keys():
			ability_slots[entity.abilities_component.abilities[ability]].button.ability = ability
		entity.abilities_component.on_gcd_update.connect(on_gcd_update)
		if old_val:
			old_val.abilities_component.on_gcd_update.disconnect(on_gcd_update)


## Called when this node becomes active. Connects signals from all slots.
func _ready() -> void:
	for ability_slot in ability_slots:
		ability_slot.on_activated.connect(func(): on_slot_activated(ability_slot))


## Called when a slot is activated. Emits up the chain.
func on_slot_activated(slot: AbilitySlot):
	if slot.button.ability:
		on_ability_activated.emit(entity, slot.button.ability)


## Called when the GCD remaining for our Entity changes. Updates progress bars on AbilitySlots.
func on_gcd_update(gcd_remaining: float, gcd_total: float):
	for slot in ability_slots:
		slot.progress = (1 - ((gcd_total - gcd_remaining) / gcd_total)) * 100
