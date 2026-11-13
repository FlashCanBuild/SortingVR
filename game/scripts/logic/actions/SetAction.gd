## SetAction is a player action that represents a movement of a slider 

class_name SetAction
extends PlayerAction

var variable: StringName
var value: int

func _init(var_name: StringName, new_value: int) -> void:
	variable = var_name
	value = new_value
