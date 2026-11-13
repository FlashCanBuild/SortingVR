## A base "interface" that represents a sorting algorithm. Inherited by all 
## other sorting algorithms we make.

class_name SortAlgorithm
extends RefCounted

# Algorithm's name as a string (e.g. Selection Sort)
func algorithm_name() -> String:
	push_error("algorithm_name() must be overridden")
	return ""

# The array of pseudocode lines to display on the backboard
func get_pseudocode() -> Array[String]:
	push_error("get_pseudocode() must be overridden")
	return []

# The variables (sliders) that we use for this algorithm (e.g. i, j, minIndex)
func get_variables() -> Array[Variable]:
	push_error("get_variables() must be overridden")
	return []

# Convert an array of integers to an array of Steps
func build(_values: Array) -> Array[Step]:
	push_error("build() must be overridden")
	return []
