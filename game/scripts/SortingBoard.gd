## SortingBoard is a container / manager class to support the entire sorting 
## process.
class_name SortingBoard
extends Node3D

@export var referee: Referee
@export var block_row: BlockRow
@export var pseudocode_board: PseudocodeBoard
@export var true_button: CompareButton
@export var false_button: CompareButton

@export var auto_move_loop_variables: bool = true
@export var start_on_ready: bool = true
@export var debug_autoplay_non_moves: bool = true
@export var debug_autoplay_delay: float = 0.5

var array_size: int = 0
var _algorithm: SortAlgorithm = SelectionSort.new()
var _values: Array = []
var _origin: Dictionary = {}
var _generation: int = 0
var _setting_up: bool = false
var _busy: bool = false


func _ready() -> void:
	array_size = block_row.slots.size() # don't guess on array size
	assert(array_size != null and array_size > 0, "SortingBoard: Number of slots is undefined or nonpositive!")
	for slot in block_row.slots:
		slot.block_placed.connect(_on_block_placed)
	block_row.temp_slot.block_placed.connect(_on_block_placed)
	referee.step_advanced.connect(_on_step_advanced)
	referee.mistake_made.connect(_on_mistake_made)
	referee.stats_changed.connect(_on_stats_changed)
	referee.restarted.connect(_on_restarted)
	referee.finished.connect(_on_finished)
	(true_button.button_interact as XRToolsInteractableAreaButton).button_pressed.connect(_on_button_pressed(true))
	(false_button.button_interact as XRToolsInteractableAreaButton).button_pressed.connect(_on_button_pressed(false))
	
	if start_on_ready:
		randomize_run(array_size)

func randomize_run(count: int = -1) -> void:
	var size := array_size if count < 1 else count
	var values: Array = range(1, size + 1)
	values.shuffle()
	start_run(values)

func reset_run() -> void:
	start_run(_values)

func start_run(values: Array) -> void:
	_values = values.duplicate()
	_rebuild_blocks()
	if pseudocode_board != null:
		pseudocode_board.set_pseudocode(_algorithm.get_pseudocode())
	referee.start(_algorithm, _values, auto_move_loop_variables)

func _rebuild_blocks() -> void:
	_generation += 1
	_origin.clear()
	_setting_up = true
	block_row.setup(_values)
	_setting_up = false
	for block in block_row.blocks:
		block.dropped.connect(_on_block_dropped)

func _on_block_placed(slot: Slot, block: SortBlock) -> void:
	if _busy:
		return
	if _setting_up:
		_origin[block] = slot
		return
	var from: Slot = _origin.get(block)
	if from == null or from == slot:
		_origin[block] = slot
		return
	if referee.submit(MoveAction.new(from.index, slot.index)):
		_origin[block] = slot
	else:
		call_deferred("_return_block", block, slot, from, _generation)

func _return_block(block: SortBlock, wrong_slot: Slot, home: Slot, generation: int) -> void:
	if generation != _generation or not is_instance_valid(block):
		return
	_busy = true
	wrong_slot.clear()
	if home.is_empty():
		home.place(block)
	_busy = false
	
func _on_button_pressed(type: bool):
	referee.submit(CompareAction.new(type))

func _on_block_dropped(block: Node3D) -> void:
	var generation := _generation
	await get_tree().process_frame
	if generation != _generation or not is_instance_valid(block):
		return
	if _holder_of(block) != null:
		return
	var home: Slot = _origin.get(block)
	if home != null and home.is_empty():
		_busy = true
		home.place(block as SortBlock)
		_busy = false

func _holder_of(block: Node3D) -> Slot:
	for slot in block_row.slots:
		if slot.block == block:
			return slot
	if block_row.temp_slot.block == block:
		return block_row.temp_slot
	return null

func _on_step_advanced(waiting_for: Step, _narrated: Array) -> void:
	print("waiting on pseudocode line ", waiting_for.line)
	if pseudocode_board != null:
		pseudocode_board.point_at(waiting_for.line)
	if debug_autoplay_non_moves and not (waiting_for is MoveStep):
		call_deferred("_autoplay", waiting_for, _generation)

func _autoplay(step: Step, generation: int) -> void:
	if debug_autoplay_delay > 0.0:
		await get_tree().create_timer(debug_autoplay_delay).timeout
	if generation != _generation:
		return
	referee.submit(_correct_action(step))

func _correct_action(step: Step) -> PlayerAction:
	var compare_step := step as CompareStep
	if compare_step != null:
		return CompareAction.new(compare_step.expected)
	var move_step := step as MoveStep
	if move_step != null:
		return MoveAction.new(move_step.from_slot, move_step.to_slot)
	var set_step := step as SetStep
	return SetAction.new(set_step.variable, set_step.value)

func _on_mistake_made(mistakes: int, _expected: Step) -> void:
	print("mistake #", mistakes)

func _on_stats_changed(progress: int, total: int, comparisons: int, mistakes: int) -> void:
	print("progress ", progress, "/", total, " | comparisons ", comparisons, " | mistakes ", mistakes)

func _on_restarted() -> void:
	print("restarted")
	call_deferred("_rebuild_blocks")

func _on_finished(_narrated: Array) -> void:
	print("finished")
	if pseudocode_board != null:
		pseudocode_board.point_at(-1)
