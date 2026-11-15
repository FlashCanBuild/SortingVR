class_name PseudocodeBoard
extends Node3D

const MARKER := ">"

@export var code_label: Label3D
@export var marker_label: Label3D
@export var current_label: Label3D

var _lines: Array[String] = []

func set_pseudocode(lines: Array[String]) -> void:
	_lines = lines.duplicate()
	point_at(-1)

func point_at(line: int) -> void:
	var numbered: Array[String] = []
	var markers: Array[String] = []
	for i in _lines.size():
		numbered.append("%d  %s" % [i, _lines[i]])
		markers.append(MARKER if i == line else "")
	code_label.text = "\n".join(PackedStringArray(numbered))
	marker_label.text = "\n".join(PackedStringArray(markers))
	if current_label != null:
		if line < 0 or line >= _lines.size():
			current_label.text = ""
		else:
			current_label.text = "Line %d: %s" % [line, _lines[line].strip_edges()]
