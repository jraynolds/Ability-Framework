extends VBoxContainer
class_name EffectReadout
## The UI panel for a single Effect on an Ability.

## The Effect we represent. Changing this updates the UI.
var effect : Effect :
	set(val):
		effect = val
		title.text = effect._title
		description.text = effect._description

## The label for the title of this Effect.
@export var title : RichTextLabel
## The label for the description of this Effect.
@export var description : RichTextLabel
