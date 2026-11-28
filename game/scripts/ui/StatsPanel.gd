class_name StatsPanel
extends PanelContainer

signal randomize_requested
signal reset_requested
signal start_requested
signal previous_requested
signal next_requested
signal menu_requested

@export var start_button: Button
@export var previous_button: Button
@export var next_button: Button
@export var menu_button: Button
@export var idle_controls: Array[Control] = []
@export var running_controls: Array[Control] = []
@export var sort_name_label: Label
@export var progress_bar: ProgressBar
@export var comparisons_label: Label
@export var mistakes_label: Label
@export var randomize_button: Button
@export var reset_button: Button
@export var description_label: Label
@export var best_label: Label
@export var average_label: Label
@export var worst_label: Label

func _ready() -> void:
	randomize_button.pressed.connect(randomize_requested.emit)
	reset_button.pressed.connect(reset_requested.emit)
	start_button.pressed.connect(start_requested.emit)
	previous_button.pressed.connect(previous_requested.emit)
	next_button.pressed.connect(next_requested.emit)
	menu_button.pressed.connect(menu_requested.emit)
	show_stats(0, 0, 0, 0)
	
func show_idle() -> void:
	_set_group_visible(idle_controls, true)
	_set_group_visible(running_controls, false)

func show_running() -> void:
	_set_group_visible(idle_controls, false)
	_set_group_visible(running_controls, true)

func _set_group_visible(group: Array[Control], shown: bool) -> void:
	for control in group:
		control.visible = shown

func set_sort_name(sort_name: String) -> void:
	sort_name_label.text = sort_name

func show_stats(progress: int, total: int, comparisons: int, mistakes: int) -> void:
	progress_bar.max_value = maxi(total, 1)
	progress_bar.value = progress
	comparisons_label.text = str(comparisons)
	mistakes_label.text = "%d / %d" % [mistakes, Referee.MAX_MISTAKES]
	
func set_algorithm_info(description: String, best: String, average: String, worst: String) -> void:
	description_label.text = description
	best_label.text = best
	average_label.text = average
	worst_label.text = worst
