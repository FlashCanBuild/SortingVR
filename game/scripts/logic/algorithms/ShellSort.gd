class_name ShellSort
extends SortAlgorithm

const PSEUDOCODE: Array[String] = [
	"for gap = n / 2; gap >= 1; gap = gap / 2",
	"    for i = gap to n - 1",
	"        int temp = arr[i]",
	"        int j = i",
	"        while j >= gap and arr[j - gap] > temp",
	"            arr[j] = arr[j - gap]",
	"            j = j - gap",
	"        arr[j] = temp",
]

func algorithm_name() -> String:
	return "Shell Sort"

func get_pseudocode() -> Array[String]:
	return PSEUDOCODE

func get_variables() -> Array[Variable]:
	var variables: Array[Variable] = [
		Variable.new(&"gap", true, Color.ORANGE),
		Variable.new(&"i", true, Color.YELLOW),
		Variable.new(&"j", false, Color.GREEN),
	]
	return variables
	
func description() -> String:
	return "Insertion sort on far-apart blocks first, then a smaller gap each pass until the gap is 1."

func best_case() -> String:
	return "O(n log n)"

func average_case() -> String:
	return "Depends on gaps"

func worst_case() -> String:
	return "O(n^2)"

func build(values: Array) -> Array[Step]:
	var a := values.duplicate()
	var steps: Array[Step] = []
	var n := a.size()
	if n < 2:
		return steps
	var gap := floori(n / 2.0)
	while gap >= 1:
		steps.append(SetStep.new(0, &"gap", gap))
		for i in range(gap, n):
			steps.append(SetStep.new(1, &"i", i))
			var key = a[i]
			steps.append(MoveStep.new(2, i, Step.TEMP_SLOT))
			var j := i
			steps.append(SetStep.new(3, &"j", j))
			while true:
				var has_room := j >= gap
				var shifts: bool = has_room and a[j - gap] > key
				if has_room:
					steps.append(CompareStep.new(4, j - gap, Step.TEMP_SLOT, shifts))
				else:
					steps.append(CompareStep.new(4, Step.TEMP_SLOT, Step.TEMP_SLOT, false, false))
				if not shifts:
					break
				a[j] = a[j - gap]
				steps.append(MoveStep.new(5, j - gap, j))
				j -= gap
				steps.append(SetStep.new(6, &"j", j))
			a[j] = key
			steps.append(MoveStep.new(7, Step.TEMP_SLOT, j))
			steps.append(SetStep.new(3, &"j", Variable.UNDEFINED))
		steps.append(SetStep.new(1, &"i", Variable.UNDEFINED))
		gap = floori(gap / 2.0)
	steps.append(SetStep.new(0, &"gap", Variable.UNDEFINED))
	return steps
