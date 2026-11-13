# Step is a base class that represents a "step" in a sorting algorithm, whether 
# it be a comparison, swap, move, set, write, or anything else.

class_name Step
extends RefCounted
# We extend RefCounted here so we don't have to do Object.free(). Yay reference
# counting - a CSE 262 concept!

# The "index" of the temporary slot we use.
const TEMP_SLOT := -2

# The line number that this Step takes place on.
var line: int

func _init(pseudocode_line: int) -> void:
	line = pseudocode_line

# Whether or not a player action satisfies the step
func is_satisfied_by(_action: PlayerAction) -> bool:
	return false
