# SetStep represents a set operation within a sorting algorithm.
# For instance, setting minIndex = i.
# In the context of this game, this means moving a slider to a specific index.

class_name SetStep
extends Step

var variable: StringName
var value: int
var loop_controlled: bool

func _init(pseudocode_line: int, var_name: StringName, new_value: int, is_loop_controlled: bool = false) -> void:
	super(pseudocode_line)
	variable = var_name
	value = new_value
	loop_controlled = is_loop_controlled

func is_satisfied_by(action: PlayerAction) -> bool:
	var set_action := action as SetAction
	return set_action != null and set_action.variable == variable and set_action.value == value
