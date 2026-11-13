## Variable represents a variable used by a sorting algorithm, specifically to 
## store indices.
## An example would be loop-controlled variables like i and j, or 
## non-loop-controlled variables like minIndex.

class_name Variable
extends RefCounted

## Sentinel array index to represent the UNDEFINED state of a variable
const UNDEFINED := -1
## Name of the variable
var name: StringName
## Whether or not the variable is "loop-controlled" (like `i` in a for loop)
var loop_controlled: bool

func _init(var_name: StringName, is_loop_controlled: bool = false) -> void:
	name = var_name
	loop_controlled = is_loop_controlled
