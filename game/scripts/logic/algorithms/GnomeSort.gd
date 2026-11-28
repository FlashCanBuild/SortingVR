class_name GnomeSort
extends SortAlgorithm

const PSEUDOCODE: Array[String] = [
	"int pos = 0",
	"while pos < n",
	"    if pos == 0 or arr[pos] >= arr[pos - 1]",
	"        pos = pos + 1",
	"    else",
	"        int temp = arr[pos]",
	"        arr[pos] = arr[pos - 1]",
	"        arr[pos - 1] = temp",
	"        pos = pos - 1",
]

func algorithm_name() -> String:
	return "Gnome Sort"

func get_pseudocode() -> Array[String]:
	return PSEUDOCODE

func get_variables() -> Array[Variable]:
	var variables: Array[Variable] = [
		Variable.new(&"pos", false, Color.YELLOW),
	]
	return variables
	
func description() -> String:
	return "Steps forward while blocks are in order, and steps back after every swap. Nicknamed \"stupid sort\"."

func best_case() -> String:
	return "O(n)"

func average_case() -> String:
	return "O(n^2)"

func worst_case() -> String:
	return "O(n^2)"

func build(values: Array) -> Array[Step]:
	var a := values.duplicate()
	var steps: Array[Step] = []
	var n := a.size()
	if n < 2:
		return steps
	var pos := 0
	steps.append(SetStep.new(0, &"pos", pos))
	while pos < n:
		var has_left := pos > 0
		var in_order: bool = not has_left or a[pos] >= a[pos - 1]
		var other := pos - 1 if has_left else pos
		steps.append(CompareStep.new(2, pos, other, in_order, has_left))
		if in_order:
			pos += 1
			steps.append(SetStep.new(3, &"pos", pos if pos < n else Variable.UNDEFINED))
		else:
			steps.append(MoveStep.new(5, pos, Step.TEMP_SLOT))
			steps.append(MoveStep.new(6, pos - 1, pos))
			steps.append(MoveStep.new(7, Step.TEMP_SLOT, pos - 1))
			var tmp = a[pos]
			a[pos] = a[pos - 1]
			a[pos - 1] = tmp
			pos -= 1
			steps.append(SetStep.new(8, &"pos", pos))
	return steps
