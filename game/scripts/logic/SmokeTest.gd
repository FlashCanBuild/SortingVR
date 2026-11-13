extends Node

var _waiting: Step
var _done: bool = false

func _ready() -> void:
	for values in [[3, 1, 2], [1, 2, 3], [2, 2, 1], [5, 4, 3, 2, 1]]:
		_check_trace(SelectionSort.new().build(values))
	var referee := Referee.new()
	add_child(referee)
	referee.step_advanced.connect(_on_step_advanced)
	referee.mistake_made.connect(_on_mistake_made)
	referee.stats_changed.connect(_on_stats_changed)
	referee.restarted.connect(_on_restarted)
	referee.finished.connect(_on_finished)
	referee.start(SelectionSort.new(), [3, 1, 2], true)
	referee.submit(AnswerAction.new(true))
	var guard := 0
	while not _done and guard < 1000:
		referee.submit(_correct_action(_waiting))
		guard += 1

func _check_trace(steps: Array[Step]) -> void:
	var current := {}
	for step in steps:
		var set_step := step as SetStep
		if set_step == null:
			continue
		var before: int = current.get(set_step.variable, Variable.UNDEFINED)
		assert(before != set_step.value, "no-op SetStep on line %d" % set_step.line)
		current[set_step.variable] = set_step.value

func _correct_action(step: Step) -> PlayerAction:
	var compare_step := step as CompareStep
	if compare_step != null:
		return AnswerAction.new(compare_step.expected)
	var move_step := step as MoveStep
	if move_step != null:
		return MoveAction.new(move_step.from_slot, move_step.to_slot)
	var set_step := step as SetStep
	return SetAction.new(set_step.variable, set_step.value)

func _on_step_advanced(waiting_for: Step, narrated: Array) -> void:
	_waiting = waiting_for
	print("waiting on line ", waiting_for.line, " | narrated before it: ", narrated.size())

func _on_mistake_made(mistakes: int, _expected: Step) -> void:
	print("mistake #", mistakes)

func _on_stats_changed(progress: int, total: int, comparisons: int, mistakes: int) -> void:
	print("progress ", progress, "/", total, " | comparisons ", comparisons, " | mistakes ", mistakes)

func _on_restarted() -> void:
	print("restarted")

func _on_finished(narrated: Array) -> void:
	_done = true
	print("finished | trailing narrated steps: ", narrated.size())
