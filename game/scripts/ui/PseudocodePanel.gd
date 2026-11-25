## PseudocodePanel displays the code for the sorting algorithm the user acts 
## out, highlighting the line of code they're currently on.
class_name PseudocodePanel
extends PanelContainer

## The array of line controls that are used for each line
@export var lines_box: VBoxContainer
## The default [Color] of the board's text
@export var normal_color := Color(1.0, 1.0, 1.0, 1.0)
## The highlighted [Color] of the board's text
@export var highlight_color: Color = Color(1.0, 0.85, 0.2, 1.0)
## 
@export var margin_box: MarginContainer
## 
@export var max_font_size := 64

const REFERENCE_SIZE := 100

## Private state variable for seeing lines of pseudocode
var _labels: Array[Label] = []

func _ready() -> void:
	resized.connect(_fit_text)

## Set [member _lines_box] to the lines of a sorting algorithm, and update the 
## board's labels
func set_pseudocode(lines: Array[String]) -> void:
	for label in _labels:
		label.queue_free()
	_labels.clear()
	for i in lines.size():
		var label := Label.new()
		label.text = "%d  %s" % [i, lines[i]]
		lines_box.add_child(label)
		_labels.append(label)
	_fit_text()
	point_at(-1)

## Set the current "focus" at a specific line (highlight it, point arrow to it, etc)[br]
## @param line line to highlight
func point_at(line: int) -> void:
	for i in _labels.size():
		var color := highlight_color if i == line else normal_color
		_labels[i].add_theme_color_override("font_color", color)

func _fit_text() -> void:
	if _labels.is_empty():
		return
	var font := _labels[0].get_theme_font("font")
	var widest := 0.0
	for label in _labels:
		widest = maxf(widest, font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, REFERENCE_SIZE).x)
	var gaps := lines_box.get_theme_constant("separation") * (_labels.size() - 1)
	var spacing := _labels[0].get_theme_constant("line_spacing") * _labels.size()
	var margins := Vector2(
		margin_box.get_theme_constant("margin_left") + margin_box.get_theme_constant("margin_right"),
		margin_box.get_theme_constant("margin_top") + margin_box.get_theme_constant("margin_bottom"))
	var available := size - get_theme_stylebox("panel").get_minimum_size() - margins
	var line_height := font.get_height(REFERENCE_SIZE)
	var ratio := minf(available.x / widest, (available.y - gaps - spacing) / (line_height * _labels.size()))
	var fitted := clampi(floori(REFERENCE_SIZE * ratio), 1, max_font_size)
	for label in _labels:
		label.add_theme_font_size_override("font_size", fitted)
