class_name FloatingPanel
extends XRToolsPickable

@export var content_scene: PackedScene
@export var resolution := Vector2(1152.0, 648.0)
@export var width := 1.2
@export var thickness := 0.03
@export var display: XRToolsViewport2DIn3D
@export var body_shape: CollisionShape3D
@export var handle_height := 0.08
@export var handle_gap := 0.02
@export var handle_mesh: MeshInstance3D

var content: Control
var panel_size: Vector2

func _ready() -> void:
	super()
	assert(content_scene != null, "FloatingPanel: content_scene is not set")
	assert(body_shape.shape is BoxShape3D, "FloatingPanel: the body shape needs a BoxShape3D")
	panel_size = Vector2(width, width * resolution.y / resolution.x)
	display.screen_size = panel_size
	display.viewport_size = resolution
	var shape := body_shape.shape.duplicate(true) as BoxShape3D
	shape.size = Vector3(panel_size.x, handle_height, thickness)
	body_shape.shape = shape
	body_shape.position = Vector3(0.0, -(panel_size.y / 2.0 + handle_gap + handle_height / 2.0), 0.0)
	assert(handle_mesh.mesh is BoxMesh, "FloatingPanel: the handle mesh needs a BoxMesh")
	var bar := handle_mesh.mesh.duplicate(true) as BoxMesh
	bar.size = shape.size
	handle_mesh.mesh = bar
	handle_mesh.position = body_shape.position
	content = content_scene.instantiate() as Control
	assert(content != null, "FloatingPanel: the content scene's root must be a Control")
	display.get_node("Viewport").add_child(content)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	
