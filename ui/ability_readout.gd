extends PanelContainer
class_name AbilityReadout
## Class for the readout UI component that appears when you hover over an AbilityButton.

## The Ability this readout represents. Changing this updates our UI.
var ability : Ability :
	set(val):
		ability = val
		icon.texture = val._icon
		title.text = ability._title
		for effect in ability._effects:
			var effect_container = effect_readout.instantiate() as EffectReadout
			readout_vbox.add_child(effect_container)
			readout_vbox.move_child(effect_container, -2)
			effect_container.effect = effect
		#show()
		#hide()
## The Icon component for the Ability.
@export var icon : TextureRect
## The title for the Ability.
@export var title : RichTextLabel
## The cooldown info label.
@export var cooldown_readout : Label
## The cast time info label.
@export var cast_time_readout : Label

## A default effect readout for each effect on the Ability.
@export var effect_readout : PackedScene
## The VBOXContainer we use for our layout.
@export var readout_vbox : VBoxContainer
