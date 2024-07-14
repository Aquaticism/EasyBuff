extends Resource
## A type of buff.
class_name Buff

@export var NAME : StringName
## The name of the buff
@export var EFFECTS : Array[BuffEffect]
## The effects of the buff.
@export_multiline var DESCRIPTION : String
## The description of the buff for the player.

var vars = {}


func destroy():
	for i in EFFECTS:
		i.free()
	free()


# Triggers all effects
func trigger(character):
	if vars.has("counter"):
		if vars["counter"] == 0:
			destroy()
		else:
			vars["counter"] -= 1
	for effect in EFFECTS:
		effect.trigger(character)
