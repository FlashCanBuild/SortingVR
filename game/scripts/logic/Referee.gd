## Referee is an abstraction that runs through the sorting algorithm with the 
## player. It ensures their correctness and simultaneously communicates with the
## slots, blocks, and control panels via signals.

class_name Referee
extends Node

signal step_advanced(waiting_for: Step, narrated: Array)
signal mistake_made(mistakes: int, expected: Step)
signal stats_changed(progress: int, total: int, comparisons: int, mistakes: int)
signal restarted
signal finished(narrated: Array)

const MAX_MISTAKES := 3

## Private variables (designated by _) by convention
## The sorting algorithm that the referee checks against
var _algorithm: SortAlgorithm
## The initial values of the array
var _initial_values: Array = []
## Whether or not the referee should auto-move loop-controlled variables
var _auto_move: bool = true
## A dictionary of variables (string -> variable)
var _variables: Dictionary = {}
## 
var _steps: Array[Step] = []
var _index: int = 0
var _mistakes: int = 0
var _comparisons: int = 0
var _progress: int = 0
var _total: int = 0

func start(algorithm: SortAlgorithm, values: Array, auto_move: bool = true) -> void:
	_algorithm = algorithm
	_initial_values = values.duplicate()
	_auto_move = auto_move
	_variables.clear()
	for variable in algorithm.get_variables():
		_variables[variable.name] = variable
	_begin()

func restart() -> void:
	restarted.emit()
	_begin()

func submit(action: PlayerAction) -> bool:
	if _index >= _steps.size():
		return false
	var step := _steps[_index]
	if step.is_satisfied_by(action):
		_on_correct(step)
		return true
	_mistakes += 1
	mistake_made.emit(_mistakes, step)
	_emit_stats()
	if _mistakes >= MAX_MISTAKES:
		restart()
	return false

func _begin() -> void:
	_steps = _algorithm.build(_initial_values)
	_index = 0
	_mistakes = 0
	_comparisons = 0
	_progress = 0
	_total = 0
	for step in _steps:
		if _needs_player(step):
			_total += 1
	_advance()

func _on_correct(step: Step) -> void:
	_progress += 1
	var compare_step := step as CompareStep
	if compare_step != null and compare_step.counts_as_comparison:
		_comparisons += 1
	_index += 1
	_advance()

func _advance() -> void:
	var narrated: Array = []
	while _index < _steps.size() and not _needs_player(_steps[_index]):
		narrated.append(_steps[_index])
		_index += 1
	_emit_stats()
	if _index >= _steps.size():
		finished.emit(narrated)
		return
	step_advanced.emit(_steps[_index], narrated)

func _needs_player(step: Step) -> bool:
	var set_step := step as SetStep
	if set_step == null:
		return true
	if set_step.value == Variable.UNDEFINED:
		return false
	var variable: Variable = _variables[set_step.variable]
	if variable.loop_controlled:
		return not _auto_move
	return true

func _emit_stats() -> void:
	stats_changed.emit(_progress, _total, _comparisons, _mistakes)
