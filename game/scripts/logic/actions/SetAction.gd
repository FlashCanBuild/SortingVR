## SetAction is a player action that represents a movement of a slider .
class_name SetAction
extends PlayerAction

## The name of the [Variable] we manipulate.
var variable: StringName
## The new index it is set to.
var value: int

func _init(var_name: StringName, new_value: int) -> void:
	variable = var_name
	value = new_value
