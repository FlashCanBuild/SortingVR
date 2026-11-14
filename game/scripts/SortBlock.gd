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
const FACE_ANGLES := [0.0, 90.0, 180.0, -90.0]

@export var mesh_instance: MeshInstance3D
@export var collision_shape: CollisionShape3D
@export var left_grab_point: Node3D
@export var right_grab_point: Node3D
@export var labels: Array[Label3D] = []

var value: int = 0
var block_height: float = 0.0

static func color_for(block_value: int, count: int) -> Color:
	var t := 0.0
	if count > 1:
		t = float(block_value - 1) / float(count - 1)
	return Color.from_hsv(lerpf(HUE_SMALL, HUE_LARGE, t), SATURATION, BRIGHTNESS)

func configure(new_value: int, count: int, max_height: float, footprint: float) -> void:
	assert(new_value >= 1 and new_value <= count)
	value = new_value
	block_height = max_height / count * value
	_resize_body(Vector3(footprint, block_height, footprint), color_for(value, count))
	_place_grab_points()
	_layout_labels(footprint)
	if not is_in_group(GROUP):
		add_to_group(GROUP)

func _resize_body(size: Vector3, color: Color) -> void:
	assert(mesh_instance.mesh is BoxMesh, "SortBlock: the mesh node needs a BoxMesh")
	assert(mesh_instance.mesh.material is StandardMaterial3D, "SortBlock: the BoxMesh needs a StandardMaterial3D")
	assert(collision_shape.shape is BoxShape3D, "SortBlock: the collision node needs a BoxShape3D")
	var box := mesh_instance.mesh.duplicate(true) as BoxMesh
	box.size = size
	(box.material as StandardMaterial3D).albedo_color = color
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0.0, size.y / 2.0, 0.0)
	var shape := collision_shape.shape.duplicate(true) as BoxShape3D
	shape.size = size
	collision_shape.shape = shape
	collision_shape.position = Vector3(0.0, size.y / 2.0, 0.0)

func _place_grab_points() -> void:
	var grab_y := block_height * GRAB_HEIGHT_FRACTION
	left_grab_point.position = Vector3(0.0, grab_y, 0.0)
	right_grab_point.position = Vector3(0.0, grab_y, 0.0)

func _layout_labels(footprint: float) -> void:
	var label_y := maxf(block_height - footprint * 0.6, footprint * 0.5)
	var face_offset := Vector3(0.0, label_y, footprint / 2.0 + LABEL_OFFSET)
	for i in labels.size():
		var angle: float = FACE_ANGLES[i % FACE_ANGLES.size()]
		var label := labels[i]
		label.text = str(value)
		label.font_size = LABEL_FONT_SIZE
		label.pixel_size = footprint * LABEL_SCALE / LABEL_FONT_SIZE
		label.rotation_degrees = Vector3(0.0, angle, 0.0)
		label.position = face_offset.rotated(Vector3.UP, deg_to_rad(angle))
