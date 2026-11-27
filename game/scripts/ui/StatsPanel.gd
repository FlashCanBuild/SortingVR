class_name StatsPanel
extends PanelContainer

signal randomize_requested
signal reset_requested

@export var sort_name_label: Label
@export var progress_bar: ProgressBar
@export var comparisons_label: Label
@export var mistakes_label: Label
@export var randomize_button: Button
@export var reset_button: Button

func _ready() -> void:
	randomize_button.pressed.connect(randomize_requested.emit)
	reset_button.pressed.connect(reset_requested.emit)
	show_stats(0, 0, 0, 0)

func set_sort_name(sort_name: String) -> void:
	sort_name_label.text = sort_name

func show_stats(progress: int, total: int, comparisons: int, mistakes: int) -> void:
	progress_bar.max_value = maxi(total, 1)
	progress_bar.value = progress
	comparisons_label.text = str(comparisons)
	mistakes_label.text = "%d / %d" % [mistakes, Referee.MAX_MISTAKES]
