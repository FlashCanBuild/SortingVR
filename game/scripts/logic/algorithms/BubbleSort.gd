class_name BubbleSort
extends SortAlgorithm

const PSEUDOCODE: Array[String] = [
	"for i = 0 to n - 2",
	"    for j = 0 to n - i - 2",
	"        if arr[j] > arr[j + 1]",
	"            int temp = arr[j]",
	"            arr[j] = arr[j + 1]",
	"            arr[j + 1] = temp",
]

func algorithm_name() -> String:
	return "Bubble Sort"

func description() -> String:
	return "Compares neighbors and swaps them if out of order, so the largest block bubbles to the end each pass."

func best_case() -> String:
	return "O(n^2)"

func average_case() -> String:
	return "O(n^2)"

func worst_case() -> String:
	return "O(n^2)"

func get_pseudocode() -> Array[String]:
	return PSEUDOCODE

func get_variables() -> Array[Variable]:
	var variables: Array[Variable] = [
		Variable.new(&"i", true, Color.YELLOW),
		Variable.new(&"j", true, Color.GREEN),
	]
	return variables

func build(values: Array) -> Array[Step]:
	var a := values.duplicate()
	var steps: Array[Step] = []
	var n := a.size()
	if n < 2:
		return steps
	for i in range(n - 1):
		steps.append(SetStep.new(0, &"i", i))
		for j in range(n - i - 1):
			steps.append(SetStep.new(1, &"j", j))
			var out_of_order: bool = a[j] > a[j + 1]
			steps.append(CompareStep.new(2, j, j + 1, out_of_order))
			if out_of_order:
				steps.append(MoveStep.new(3, j, Step.TEMP_SLOT))
				steps.append(MoveStep.new(4, j + 1, j))
				steps.append(MoveStep.new(5, Step.TEMP_SLOT, j + 1))
				var tmp = a[j]
				a[j] = a[j + 1]
				a[j + 1] = tmp
		steps.append(SetStep.new(1, &"j", Variable.UNDEFINED))
	steps.append(SetStep.new(0, &"i", Variable.UNDEFINED))
	return steps
