## PseudocodeBoard displays the code for the sorting algorithm the user acts 
## out, highlighting the line of code they're currently on.
class_name PseudocodeBoard
extends Node3D

## The array of [Label3D]s that are used for each line
@export var line_labels: Array[Label3D] = []
## The default [Color] of the board's text
@export var normal_color: Color = Color(0.75, 0.8, 0.85)
## The highlighted [Color] of the board's text
@export var highlight_color: Color = Color(1.0, 0.85, 0.2)

## Private state variable for seeing lines of pseudocode
var _lines: Array[String] = []

## Set [member _lines] to the lines of a sorting algorithm, and update the 
## board's labels
func set_pseudocode(lines: Array[String]) -> void:
	assert(lines.size() <= line_labels.size(), "PseudocodeBoard: not enough line labels for this algorithm")
	_lines = lines.duplicate()
	for i in line_labels.size():
		line_labels[i].text = "%d  %s" % [i, _lines[i]] if i < _lines.size() else ""
	point_at(-1)

## Set the current "focus" at a specific line (highlight it, point arrow to it, etc)[br]
## @param line line to highlight
func point_at(line: int) -> void:
	for i in line_labels.size():
		line_labels[i].modulate = highlight_color if i == line else normal_color
