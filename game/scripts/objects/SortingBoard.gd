## SortingBoard is a container / manager class to support the entire sorting 
## process.
class_name SortingBoard
extends Node3D

## The logical manager - determines correct steps to take for the player
@export var referee: Referee
## A series of [Slot]s to hold array values
@export var block_row: BlockRow
## A display of a sorting algorithm's pseudocode
@export var pseudocode_panel: FloatingPanel
## The slider rack
@export var slider_rack: SliderRack
## A button to press upon a [CompareStep] necessitating `true`
@export var true_button: CompareButton
## A button to press upon a [CompareStep] necessitating `false`
@export var false_button: CompareButton
## 
@export var snap_preview: SnapPreview

## Whether loop variables' sliders (like i and j) will automatically move upon 
## increment, decrement, and definition
@export var auto_move_loop_variables: bool = true
## Whether the sorting board will automatically start on game start
@export var start_on_ready: bool = true
## 
@export var compare_cooldown_sec: float = 1.0
# [jag329] these two should be removed later
## Whether or not the debug will automatically play moves that we haven't 
## implemented yet
@export var debug_autoplay_non_moves: bool = true
## Time delay between steps during the debug autoplay
@export var debug_autoplay_delay: float = 0.5

## Size of the array to sort
var array_size: int = 0
## Algorithm to use while sorting the array
var _algorithm: SortAlgorithm = SelectionSort.new()
## The starting state of the array that we sort.
var _values: Array = []
## Mapping between a SortBlock (key) and a Slot (value). 
var _origin: Dictionary = {}
## Acts as a cancellation token (or version counter) to prevent stale async 
## callbacks from running after the board has been reset or rebuilt.
var _generation: int = 0
## Whether the BlockRow is busy setting up blocks. If true, accessors shouldn't 
## treat the BlockRow's contents as final.
var _setting_up: bool = false
## True whenever the SortingBoard is calling a child to move or remove blocks. 
## This flag is needed due to the signals that are used.
var _busy: bool = false
## 
var _last_compare_time: float = -INF
##
var _pseudocode: PseudocodePanel

## Connect signals and set up the SortingBoard upon start.
func _ready() -> void:
	if not pseudocode_panel.is_node_ready():
		await pseudocode_panel.ready
	_pseudocode = pseudocode_panel.content as PseudocodePanel
	assert(_pseudocode != null, "SortingBoard: the panel's content is not a PseudocodePanel")
	array_size = block_row.slots.size() # don't guess on array size
	assert(array_size != null and array_size > 0, "SortingBoard: Number of slots is undefined or nonpositive!")
	# Connect signals
	for slot in block_row.slots:
		slot.block_placed.connect(_on_block_placed)
	block_row.temp_slot.block_placed.connect(_on_block_placed)
	referee.step_advanced.connect(_on_step_advanced)
	referee.mistake_made.connect(_on_mistake_made)
	referee.stats_changed.connect(_on_stats_changed)
	referee.restarted.connect(_on_restarted)
	referee.finished.connect(_on_finished)
	(true_button.button_interact as XRToolsInteractableAreaButton).button_pressed.connect(_on_compare_pressed.bind(true))
	(false_button.button_interact as XRToolsInteractableAreaButton).button_pressed.connect(_on_compare_pressed.bind(false))
	slider_rack.slider_released.connect(_on_slider_released)
	
	if start_on_ready:
		randomize_run(array_size)

## Reshuffle the array and start a new run.[br]
## @param count		Optional new count for the array
func randomize_run(count: int = -1) -> void:
	var size := array_size if count < 1 else count
	var values: Array = range(1, size + 1)
	values.shuffle()
	start_run(values)

## Reset the current run with the same order of starting values
func reset_run() -> void:
	start_run(_values)

## Start a run with a certain set of starting values[br]
## @param values	Starting values of the array
func start_run(values: Array) -> void:
	_values = values.duplicate()
	_rebuild_blocks()
	slider_rack.setup(_algorithm.get_variables(), block_row, _values.size(), auto_move_loop_variables)
	if _pseudocode:
		_pseudocode.set_pseudocode(_algorithm.get_pseudocode())
	referee.start(_algorithm, _values, auto_move_loop_variables)

## Rebuild the blocks on top of the slots
func _rebuild_blocks() -> void:
	_generation += 1
	_origin.clear()
	_setting_up = true
	block_row.setup(_values)
	_setting_up = false
	for block in block_row.blocks:
		block.dropped.connect(_on_block_dropped)

## Signal handler for slots when a block is placed onto them.[br]
## @param slot		slot the block was placed on[br]
## @param block 	the block that was placed
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
		# the block was placed in the incorrect place, return it.
		call_deferred("_return_block", block, slot, from, _generation)

## Return a block from an incorrect slot to its former slot[br]
## @param block			The block that was incorrectly placed[br]
## @param wrong_slot	The incorrect slot (the slot the block is currently 
## 						on) [br]
## @param home			The previous slot the block was placed on [br]
## @param generation	The cancellation token
func _return_block(block: SortBlock, wrong_slot: Slot, home: Slot, generation: int) -> void:
	if generation != _generation or not is_instance_valid(block):
		return
	_busy = true
	wrong_slot.clear()
	if home.is_empty():
		home.place(block)
	_busy = false
	
## Trigger a [CompareAction] with a given type depending on the button that is 
## pressed[br]
## @param _button	the button that was pressed[br]
## @param answer	the type of button that is pressed (TRUE/FALSE)
func _on_compare_pressed(_button, answer: bool) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_compare_time < compare_cooldown_sec:
		return
	_last_compare_time = now
	referee.submit(CompareAction.new(answer))

## Trigger a teleport back to the block's home depending on where the block 
## drops[br]
## @param block	the block that was dropped
func _on_block_dropped(block: Node3D) -> void:
	print("f", Engine.get_process_frames(), " dropped signal block ", (block as SortBlock).value)
	var generation := _generation
	await get_tree().process_frame
	if generation != _generation or not is_instance_valid(block) or _holder_of(block) != null or (block as SortBlock).is_picked_up():
		return
	var target := snap_preview.nearest_slot_for(block as SortBlock)
	if target != null:
		target.place(block as SortBlock)
		return
	var home: Slot = _origin.get(block)
	if home != null and home.is_empty():
		_busy = true
		home.place(block as SortBlock)
		_busy = false

## Get the slot that holds this block[br]
## @param block 	block to search for
func _holder_of(block: Node3D) -> Slot:
	for slot in block_row.slots:
		if slot.block == block:
			return slot
	if block_row.temp_slot.block == block:
		return block_row.temp_slot
	return null

## Update the autoplay and pseudocode board upon a completed step[br]
## @param waiting_for	the step we're now waiting on[br]
## @param _narrated		unused variable for any steps that aren't 
func _on_step_advanced(waiting_for: Step, narrated: Array) -> void:
	_apply_narrated(narrated)
	print("waiting on pseudocode line ", waiting_for.line)
	if _pseudocode:
		_pseudocode.point_at(waiting_for.line)
	if debug_autoplay_non_moves and not (waiting_for is MoveStep or waiting_for is CompareStep):
		call_deferred("_autoplay", waiting_for, _generation)

## Autoplay a step (complete a step without player input)[br]
## @param step			step to autoplay[br]
## @param generation	The cancellation token
func _autoplay(step: Step, generation: int) -> void:
	if debug_autoplay_delay > 0.0:
		await get_tree().create_timer(debug_autoplay_delay).timeout
	if generation != _generation:
		return
	referee.submit(_correct_action(step))

## Generate the correct action for a given step[br]
## @param step	step[br]
## @returns		correct action
func _correct_action(step: Step) -> PlayerAction:
	var compare_step := step as CompareStep
	if compare_step != null:
		return CompareAction.new(compare_step.expected)
	var move_step := step as MoveStep
	if move_step != null:
		return MoveAction.new(move_step.from_slot, move_step.to_slot)
	var set_step := step as SetStep
	return SetAction.new(set_step.variable, set_step.value)

## Events to trigger upon a mistake[br]
## @param mistakes		number of mistakes that we've made so far[br]
## @param _expected		the step that was expected for the player to make
func _on_mistake_made(mistakes: int, _expected: Step) -> void:
	print("mistake #", mistakes)

## Events to trigger upon a change in statistics[br]
## @param progress		the number of player-done steps meaning[br]
## @param total			the total number of steps[br]
## @param comparisons	the amount of comparisons made[br] 
## @param mistakes		the number of mistakes made
func _on_stats_changed(progress: int, total: int, comparisons: int, mistakes: int) -> void:
	print("progress ", progress, "/", total, " | comparisons ", comparisons, " | mistakes ", mistakes)

## Events to trigger upon a restart (defer call to rebuild blocks)
func _on_restarted() -> void:
	print("restarted")
	slider_rack.reset_all()
	call_deferred("_rebuild_blocks")

## Events to trigger upon a finish[br]
## @param _narrated		the remaining steps to auto-complete
func _on_finished(narrated: Array) -> void:
	print("finished")
	_apply_narrated(narrated)
	if _pseudocode:
		_pseudocode.point_at(-1)
		
func _apply_narrated(narrated: Array) -> void:
	for step in narrated:
		var set_step := step as SetStep
		if set_step != null:
			slider_rack.apply(set_step.variable, set_step.value)

func _on_slider_released(slider: IndexSlider, index: int) -> void:
	if referee.submit(SetAction.new(slider.variable.name, index)):
		slider.commit(index)
	else:
		slider.revert()
