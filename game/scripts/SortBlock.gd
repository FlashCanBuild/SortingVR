## STILL NEED TO DOCUMENT 11/13/2026

@tool
class_name SortBlock
extends XRToolsPickable

const GROUP := "SortBlock"
const GRAB_HEIGHT_FRACTION := 0.25
const HUE_SMALL := 1.0
const HUE_LARGE := 0.66
const SATURATION := 0.8
const BRIGHTNESS := 0.95
const LABEL_FONT_SIZE := 64
const LABEL_SCALE := 0.6
const LABEL_OFFSET := 0.002

@export var mesh_instance: MeshInstance3D
@export var collision_shape: CollisionShape3D
@export var left_grab_point: Node3D
@export var right_grab_point: Node3D

@export_group("Editor Preview")
@export_range(1, 20) var preview_value: int = 1: set = _set_preview_value
@export_range(1, 20) var preview_count: int = 5: set = _set_preview_count
@export_range(0.1, 3.0, 0.05) var preview_max_height: float = 1.0: set = _set_preview_max_height

var value: int = 0
var block_height: float = 0.0

static func color_for(block_value: int, count: int) -> Color:
	var t := 0.0
	if count > 1:
		t = float(block_value - 1) / float(count - 1)
	return Color.from_hsv(lerpf(HUE_SMALL, HUE_LARGE, t), SATURATION, BRIGHTNESS)

func _ready() -> void:
	super()
	_refresh_preview()

func configure(new_value: int, count: int, max_height: float) -> void:
	assert(new_value >= 1 and new_value <= count)
	value = new_value
	var unit := max_height / count
	block_height = unit * value
	_build_body(Vector3(unit, block_height, unit), color_for(value, count))
	_place_grab_points()
	_build_labels(unit)
	if not is_in_group(GROUP):
		add_to_group(GROUP)

func _set_preview_value(new_value: int) -> void:
	preview_value = new_value
	_refresh_preview()

func _set_preview_count(new_count: int) -> void:
	preview_count = new_count
	_refresh_preview()

func _set_preview_max_height(new_height: float) -> void:
	preview_max_height = new_height
	_refresh_preview()

func _refresh_preview() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return
	if mesh_instance == null or collision_shape == null:
		return
	if left_grab_point == null or right_grab_point == null:
		return
	configure(clampi(preview_value, 1, preview_count), preview_count, preview_max_height)

func _build_body(size: Vector3, color: Color) -> void:
	var box := BoxMesh.new()
	box.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	box.material = material
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0.0, size.y / 2.0, 0.0)
	var shape := BoxShape3D.new()
	shape.size = size
	collision_shape.shape = shape
	collision_shape.position = Vector3(0.0, size.y / 2.0, 0.0)

func _place_grab_points() -> void:
	var grab_y := block_height * GRAB_HEIGHT_FRACTION
	left_grab_point.position = Vector3(0.0, grab_y, 0.0)
	right_grab_point.position = Vector3(0.0, grab_y, 0.0)

func _build_labels(unit: float) -> void:
	for child in get_children():
		if child is Label3D:
			child.queue_free()
	var label_y := maxf(block_height - unit * 0.6, unit * 0.5)
	var face_offset := Vector3(0.0, label_y, unit / 2.0 + LABEL_OFFSET)
	for angle in [0.0, 90.0, 180.0, -90.0]:
		var label := Label3D.new()
		label.text = str(value)
		label.font_size = LABEL_FONT_SIZE
		label.pixel_size = unit * LABEL_SCALE / LABEL_FONT_SIZE
		label.rotation_degrees.y = angle
		label.position = face_offset.rotated(Vector3.UP, deg_to_rad(angle))
		add_child(label)
