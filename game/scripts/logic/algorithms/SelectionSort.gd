## Selection Sort is an O(n^2) sorting algorithm that finds the minimum of 
## subarrays.

class_name SelectionSort
extends SortAlgorithm

const PSEUDOCODE: Array[String] = [
	"for i = 0 to n - 2",
	"    int minIndex = i",
	"    for j = i + 1 to n - 1",
	"        if arr[j] < arr[minIndex]",
	"            minIndex = j",
	"    if minIndex != i",
	"        int temp = arr[i]",
	"        arr[i] = arr[minIndex]",
	"        arr[minIndex] = temp",
]

func algorithm_name() -> String:
	return "Selection Sort"

func get_pseudocode() -> Array[String]:
	return PSEUDOCODE

func get_variables() -> Array[Variable]:
	var variables: Array[Variable] = [
		Variable.new(&"i", true),
		Variable.new(&"j", true),
		Variable.new(&"minIndex"),
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
		var min_idx := i
		steps.append(SetStep.new(1, &"minIndex", min_idx))
		for j in range(i + 1, n):
			steps.append(SetStep.new(2, &"j", j))
			var smaller: bool = a[j] < a[min_idx]
			steps.append(CompareStep.new(3, j, min_idx, smaller))
			if smaller:
				min_idx = j
				steps.append(SetStep.new(4, &"minIndex", min_idx))
		steps.append(SetStep.new(2, &"j", Variable.UNDEFINED))
		var needs_swap := min_idx != i
		steps.append(CompareStep.new(5, i, min_idx, needs_swap, false))
		if needs_swap:
			steps.append(MoveStep.new(6, i, Step.TEMP_SLOT))
			steps.append(MoveStep.new(7, min_idx, i))
			steps.append(MoveStep.new(8, Step.TEMP_SLOT, min_idx))
			var tmp = a[i]
			a[i] = a[min_idx]
			a[min_idx] = tmp
		steps.append(SetStep.new(0, &"minIndex", Variable.UNDEFINED))
	steps.append(SetStep.new(0, &"i", Variable.UNDEFINED))
	return steps
