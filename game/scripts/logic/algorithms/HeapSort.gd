class_name HeapSort
extends SortAlgorithm

const PSEUDOCODE: Array[String] = [
	"for start = n / 2 - 1 down to 0",
	"    siftDown(start, n)",
	"for end = n - 1 down to 1",
	"    swap(arr[0], arr[end])",
	"    siftDown(0, end)",
	"siftDown(root, size):",
	"    while 2 * root + 1 < size",
	"        child = 2 * root + 1",
	"        if child + 1 < size and arr[child] < arr[child + 1]",
	"            child = child + 1",
	"        if arr[root] < arr[child]",
	"            swap(arr[root], arr[child])",
	"            root = child",
	"        else",
	"            break",
]

func algorithm_name() -> String:
	return "Heap Sort"

func get_pseudocode() -> Array[String]:
	return PSEUDOCODE

func get_variables() -> Array[Variable]:
	var variables: Array[Variable] = [
		Variable.new(&"start", true, Color.YELLOW),
		Variable.new(&"end", true, Color.ORANGE),
		Variable.new(&"root", false, Color.CYAN),
		Variable.new(&"child", false, Color.GREEN),
	]
	return variables

func build(values: Array) -> Array[Step]:
	var a := values.duplicate()
	var steps: Array[Step] = []
	var n := a.size()
	if n < 2:
		return steps
	for start in range(floori(n / 2.0) - 1, -1, -1):
		steps.append(SetStep.new(0, &"start", start))
		steps.append(SetStep.new(1, &"root", start))
		_sift_down(steps, a, start, n)
	steps.append(SetStep.new(0, &"start", Variable.UNDEFINED))
	for end in range(n - 1, 0, -1):
		steps.append(SetStep.new(2, &"end", end))
		steps.append(MoveStep.new(3, 0, Step.TEMP_SLOT))
		steps.append(MoveStep.new(3, end, 0))
		steps.append(MoveStep.new(3, Step.TEMP_SLOT, end))
		_swap(a, 0, end)
		steps.append(SetStep.new(4, &"root", 0))
		_sift_down(steps, a, 0, end)
	steps.append(SetStep.new(2, &"end", Variable.UNDEFINED))
	return steps

func _sift_down(steps: Array[Step], a: Array, root: int, size: int) -> void:
	var child := Variable.UNDEFINED
	while true:
		var has_child := 2 * root + 1 < size
		steps.append(CompareStep.new(6, root, root, has_child, false))
		if not has_child:
			break
		child = 2 * root + 1
		steps.append(SetStep.new(7, &"child", child))
		var has_right := child + 1 < size
		var right_bigger: bool = has_right and a[child] < a[child + 1]
		if has_right:
			steps.append(CompareStep.new(8, child, child + 1, right_bigger))
		else:
			steps.append(CompareStep.new(8, child, child, false, false))
		if right_bigger:
			child += 1
			steps.append(SetStep.new(9, &"child", child))
		var needs_swap: bool = a[root] < a[child]
		steps.append(CompareStep.new(10, root, child, needs_swap))
		if not needs_swap:
			break
		steps.append(MoveStep.new(11, root, Step.TEMP_SLOT))
		steps.append(MoveStep.new(11, child, root))
		steps.append(MoveStep.new(11, Step.TEMP_SLOT, child))
		_swap(a, root, child)
		root = child
		steps.append(SetStep.new(12, &"root", root))
	if child != Variable.UNDEFINED:
		steps.append(SetStep.new(5, &"child", Variable.UNDEFINED))
	steps.append(SetStep.new(5, &"root", Variable.UNDEFINED))

func _swap(a: Array, i: int, j: int) -> void:
	var tmp = a[i]
	a[i] = a[j]
	a[j] = tmp
