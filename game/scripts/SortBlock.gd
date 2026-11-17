## SortBlock is a grabbable object in-game that represents a value in an array. 
## The player manipulates them to sort the array and act out a given sorting 
## algorithm.[br]
## We utilize XRTools' [XRToolsPickable] class to implement the grabbing 
## behavior.
@tool
class_name SortBlock
extends XRToolsPickable

## The group that all SortBlock instances belong to.
const GROUP := "SortBlock"
## The fraction of the block's height at which the grab points will be placed.
const GRAB_HEIGHT_FRACTION := 0.25

# HSV settings
## The smallest block's hue
const HUE_SMALL := 1.0
## The largest block's hue
const HUE_LARGE := 0.66
## The saturation of every block's color
const SATURATION := 0.8
## The brightness, or "value", of every block's color
const BRIGHTNESS := 0.95

# Label settings
## The font size of every block's label
const LABEL_FONT_SIZE := 64
## The scale of every block's label
const LABEL_SCALE := 0.6
## The distance between the label and the face of the block
const LABEL_OFFSET := 0.002
## The angles at which a label will be placed
const FACE_ANGLES := [0.0, 90.0, 180.0, -90.0]

# Exports
## The mesh used for the block
@export var mesh_instance: MeshInstance3D
## The block's collision shape
@export var collision_shape: CollisionShape3D
## The left hand's grab point
@export var left_grab_point: XRToolsGrabPointHand
## The right hand's grab point
@export var right_grab_point: XRToolsGrabPointHand
## The four labels that show the value of the block
@export var labels: Array[Label3D] = []

## The block's value
var value: int = 0
## The height of the block (in meters)
var block_height: float = 0.0

## The color corresponding to a given value. Calculated using a lerp function on
## an HSV value.[br]
## @param block_value	the value of this block[br]
## @param count			the total number of blocks[br]
## @returns 			the color for this block
static func color_for(block_value: int, count: int) -> Color:
	var t := 0.0
	if count > 1:
		t = float(block_value - 1) / float(count - 1)
	return Color.from_hsv(lerpf(HUE_SMALL, HUE_LARGE, t), SATURATION, BRIGHTNESS)

## Configure the [SortBlock], setting up its body, grab points, value, group, etc.
## [br]
## @param new_value		The new value for this SortBlock[br]
## @param count			The size of the array we're sorting[br]
## @param max_height	The maximum height of a SortBlock[br]
## @param footprint		The width/length of the SortBlock
func configure(new_value: int, count: int, max_height: float, footprint: float) -> void:
	assert(new_value >= 1 and new_value <= count)
	value = new_value
	block_height = max_height / count * value
	_resize_body(Vector3(footprint, block_height, footprint), color_for(value, count))
	_place_grab_points()
	_layout_labels(footprint)
	if not is_in_group(GROUP):
		add_to_group(GROUP)

## Set up the block's mesh and collision shape[br]
## @param size	A [Vector3] denoting the block's size (length, height, width)[br]
## @param color	The desired [Color] of the block
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

## Place the grab points in the correct spot according to its height
func _place_grab_points() -> void:
	var grab_y := block_height * GRAB_HEIGHT_FRACTION
	left_grab_point.position = Vector3(0.0, grab_y, 0.0)
	right_grab_point.position = Vector3(0.0, grab_y, 0.0)

## Layout the labels according to the block's footprint and height[br]
## @param footprint		The width/length of the SortBlock
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
