class_name InsertionSort
extends SortAlgorithm

const PSEUDOCODE: Array[String] = [
	"for i = 1 to n - 1",
	"    int temp = arr[i]",
	"    int j = i",
	"    while j > 0 and arr[j - 1] > temp",
	"        arr[j] = arr[j - 1]",
	"        j = j - 1",
	"    arr[j] = temp",
]

func algorithm_name() -> String:
	return "Insertion Sort"

func description() -> String:
	return "Takes each block and slides it left into its correct spot among the sorted blocks."

func best_case() -> String:
	return "O(n)"

func average_case() -> String:
	return "O(n^2)"

func worst_case() -> String:
	return "O(n^2)"

func get_pseudocode() -> Array[String]:
	return PSEUDOCODE

func get_variables() -> Array[Variable]:
	var variables: Array[Variable] = [
		Variable.new(&"i", true, Color.YELLOW),
		Variable.new(&"j", false, Color.GREEN),
	]
	return variables

func build(values: Array) -> Array[Step]:
	var a := values.duplicate()
	var steps: Array[Step] = []
	var n := a.size()
	if n < 2:
		return steps
	for i in range(1, n):
		steps.append(SetStep.new(0, &"i", i))
		var key = a[i]
		steps.append(MoveStep.new(1, i, Step.TEMP_SLOT))
		var j := i
		steps.append(SetStep.new(2, &"j", j))
		while true:
			var has_left := j > 0
			var shifts: bool = has_left and a[j - 1] > key
			if has_left:
				steps.append(CompareStep.new(3, j - 1, Step.TEMP_SLOT, shifts))
			else:
				steps.append(CompareStep.new(3, Step.TEMP_SLOT, Step.TEMP_SLOT, false, false))
			if not shifts:
				break
			a[j] = a[j - 1]
			steps.append(MoveStep.new(4, j - 1, j))
			j -= 1
			steps.append(SetStep.new(5, &"j", j))
		a[j] = key
		steps.append(MoveStep.new(6, Step.TEMP_SLOT, j))
		steps.append(SetStep.new(2, &"j", Variable.UNDEFINED))
	steps.append(SetStep.new(0, &"i", Variable.UNDEFINED))
	return steps
