## Referee is an abstraction that runs through the sorting algorithm with the 
## player. It ensures their correctness and simultaneously communicates with the
## slots, blocks, and control panels via signals.

class_name Referee
extends Node

## Send out a signal with the step we're currently waiting for, and an optional 
## amount of automatic "narrated" steps that we wish the board to automatically 
## complete.
signal step_advanced(waiting_for: Step, narrated: Array)
## There was a mistake made. Show the number of mistakes remaining
signal mistake_made(mistakes: int, expected: Step)
## There was a change in statistics regarding the run (progress, total, 
## comparisons, mistakes)
signal stats_changed(progress: int, total: int, comparisons: int, mistakes: int)
## The referee is restarting the algorithm from the beginning
signal restarted
## The player has finished the algorithm, with a certain number of automated 
## steps.
signal finished(narrated: Array)

## Maximum mistakes the player can make before we restart the algorithm
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
## The array of correct steps to solving the algorithm
var _steps: Array[Step] = []
## Which step we're currently on
var _index: int = 0
## Number of mistakes made by the player
var _mistakes: int = 0
## Number of comparisons made so far
var _comparisons: int = 0
## Number of player-made steps we've currently made
var _progress: int = 0
## Total number of player-made steps
var _total: int = 0

## PUBLIC METHODS

## Start the algorithm with a certain amount of values.
## @param algorithm 	the algorithm to start 
## @param values		the values of the array to use
## @param auto_move		whether or not the referee should auto-set 
## 						loop-controlled variables
func start(algorithm: SortAlgorithm, values: Array, auto_move: bool = true) -> void:
	_algorithm = algorithm
	_initial_values = values.duplicate()
	_auto_move = auto_move
	_variables.clear()
	for variable in algorithm.get_variables():
		_variables[variable.name] = variable
	_begin()

## Start the algorithm from scratch with the same starting values
func restart() -> void:
	restarted.emit()
	_begin()

## Submit a given PlayerAction, and whether it is correct or not.
## @param action	the player's action
## @returns 		whether or not the player's action was correct or not
func submit(action: PlayerAction) -> bool:
	if _index >= _steps.size():
		return false
	var step := _steps[_index]
	## Check if the step is satisfied by the player's action (i.e. the player's 
	## action is correct)
	if step.is_satisfied_by(action):
		_on_correct(step)
		return true
	## Otherwise, emit a mistake
	_mistakes += 1
	mistake_made.emit(_mistakes, step)
	_emit_stats()
	if _mistakes >= MAX_MISTAKES:
		restart()
	return false
	
## PRIVATE METHODS

## Begin the algorithm from the beginning
func _begin() -> void:
	_steps = _algorithm.build(_initial_values)
	_index = 0
	_mistakes = 0
	_comparisons = 0
	_progress = 0
	_total = 0
	# we don't need to emit stats here since _advance() does it.
	for step in _steps:
		if _needs_player(step):
			_total += 1
	_advance()

## Upon a correct step, advance to the next step
## @param step	The correct step that was made by the player
func _on_correct(step: Step) -> void:
	_progress += 1
	var compare_step := step as CompareStep
	if compare_step != null and compare_step.counts_as_comparison:
		_comparisons += 1
	_index += 1
	_advance()

## Advance to the next player-required step
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

## Whether or not a step requires the player to complete it
## @param step	step to check
## @returns 	whether or not the step requires the player
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

## Emit the Referee's statistics to the stats_changed signal
func _emit_stats() -> void:
	stats_changed.emit(_progress, _total, _comparisons, _mistakes)
