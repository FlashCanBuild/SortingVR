## SliderRack is a collection of all index variables used for the sorting 
## algorithm as well as their sliders.
@tool
class_name SliderRack
extends Node3D

## Upon a slider releasing, emit a signal with itself and the index it moved to.
signal slider_released(slider: IndexSlider, index: int)

## The vertical spacing between sliders
const PREVIEW_HEIGHT := 0.08
const PREVIEW_DEPTH := 0.04
const PREVIEW_COLOR := Color(0.2, 0.9, 1.0)

@export var anchor: Marker3D
@export var slider_scene: PackedScene

@export var preview_row: Node3D
@export_range(2, 20) var preview_count: int = 5
@export_range(1, 8) var preview_variables: int = 3
@export var SPACING := 0.25

var _preview_mesh: ImmediateMesh

var _sliders: Dictionary = {}

func _ready() -> void:
	set_process(Engine.is_editor_hint())
	if not Engine.is_editor_hint():
		return
	_preview_mesh = ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = PREVIEW_COLOR
	var preview := MeshInstance3D.new()
	preview.top_level = true
	preview.mesh = _preview_mesh
	preview.material_override = material
	add_child(preview)
	
func _process(_delta: float) -> void:
	_draw_preview()

func setup(variables: Array[Variable], block_row: BlockRow, count: int, auto_move: bool) -> void:
	_clear()
	var step := block_row.slot_spacing(count)
	var axes := anchor.global_transform.basis.orthonormalized()
	var first_slot := block_row.slot_for_index(0).global_position
	var along := (first_slot - anchor.global_position).dot(axes.x)
	var track_origin := anchor.global_position + axes.x * along
	for i in variables.size():
		var slider := slider_scene.instantiate() as IndexSlider
		add_child(slider)
		slider.global_transform = Transform3D(axes, track_origin + axes.z * SPACING * i)
		slider.configure(variables[i], count, step, auto_move)
		slider.released_at.connect(_on_released_at)
		_sliders[variables[i].name] = slider

func apply(variable_name: StringName, index: int) -> void:
	var slider: IndexSlider = _sliders.get(variable_name)
	if slider != null:
		slider.show_index(index)

func reset_all() -> void:
	for slider in _sliders.values():
		(slider as IndexSlider).show_index(Variable.UNDEFINED)

func _clear() -> void:
	for slider in _sliders.values():
		slider.queue_free()
	_sliders.clear()

func _on_released_at(slider: IndexSlider, index: int) -> void:
	slider_released.emit(slider, index)

## PREVIEW STUFF
func _draw_preview() -> void:
	if _preview_mesh == null:
		return
	_preview_mesh.clear_surfaces()
	if anchor == null or preview_row == null:
		return
	var slots = preview_row.get("slots")
	if slots == null:
		return
	var axes := anchor.global_transform.basis.orthonormalized()
	var positions: Array[Vector3] = []
	for slot in slots:
		if slot != null:
			positions.append((slot as Node3D).global_position)
	positions.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.dot(axes.x) < b.dot(axes.x))
	var count := mini(preview_count, positions.size())
	if count < 2:
		return
	var step := INF
	for i in range(count - 1):
		step = minf(step, positions[i].distance_to(positions[i + 1]))
	var along := (positions[0] - anchor.global_position).dot(axes.x)
	var track_origin := anchor.global_position + axes.x * along
	_preview_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for i in preview_variables:
		_add_track(Transform3D(axes, track_origin + axes.z * SPACING * i), step, count)
	_preview_mesh.surface_end()
	
func _add_track(frame: Transform3D, step: float, count: int) -> void:
	var lo := Vector3(-step, -PREVIEW_HEIGHT / 2.0, -PREVIEW_DEPTH / 2.0)
	var hi := Vector3((count - 1) * step, PREVIEW_HEIGHT / 2.0, PREVIEW_DEPTH / 2.0)
	var corners: Array[Vector3] = []
	for x in [lo.x, hi.x]:
		for y in [lo.y, hi.y]:
			for z in [lo.z, hi.z]:
				corners.append(frame * Vector3(x, y, z))
	for a in corners.size():
		for b in range(a + 1, corners.size()):
			if (a ^ b) in [1, 2, 4]:
				_preview_mesh.surface_add_vertex(corners[a])
				_preview_mesh.surface_add_vertex(corners[b])
	for k in range(-1, count):
		_preview_mesh.surface_add_vertex(frame * Vector3(k * step, lo.y, 0.0))
		_preview_mesh.surface_add_vertex(frame * Vector3(k * step, hi.y, 0.0))
