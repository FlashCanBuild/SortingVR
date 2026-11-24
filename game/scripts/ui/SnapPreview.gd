## TO BE DOCUMENTED

class_name SnapPreview
extends Node3D

@export var block_row: BlockRow
@export var snap_range: float = 0.3
@export_range(0.0, 1.0) var ghost_alpha: float = 0.8

static var EDGE_INDICES : PackedInt32Array = PackedInt32Array([
	0, 1, 1, 2, 2, 3, 3, 0,
	4, 5, 5, 6, 6, 7, 7, 4,
	0, 4, 1, 5, 2, 6, 3, 7,
])

var _ghost: MeshInstance3D
var _shown_block: SortBlock
var _shown_slot: Slot

func _ready() -> void:
	_ghost = MeshInstance3D.new()
	_ghost.top_level = true
	_ghost.visible = false
	add_child(_ghost)
	
var _debug_last: String = ""

func _debug_report(block: SortBlock, slot: Slot) -> void:
	var picked: Array = []
	for b in block_row.blocks:
		if is_instance_valid(b) and b.is_picked_up():
			picked.append("%d(in_slot=%s)" % [b.value, _is_in_slot(b)])
	var report := "picked=%s held=%s slot=%s" % [
		str(picked),
		str(block.value) if block != null else "none",
		str(slot.index) if slot != null else "none",
	]
	if block != null and slot == null:
		var closest := INF
		for s in _candidate_slots():
			closest = minf(closest, s.global_position.distance_to(block.global_position))
		report += " closest=%.1f" % closest
	if report != _debug_last:
		_debug_last = report
		print(report)

func _process(_delta: float) -> void:
	var block := _held_block()
	var slot := nearest_slot_for(block)
	_debug_report(block, slot)
	if block == null or slot == null:
		_ghost.visible = false
		return
	if block != _shown_block:
		var box := block.mesh_instance.mesh as BoxMesh
		_ghost.mesh = _build_edges(box.size)
		_ghost.material_override = _make_material(box)
		_shown_block = block
		_shown_slot = null
	if slot != _shown_slot:
		_ghost.global_transform = slot.global_transform * Transform3D(Basis(), block.mesh_instance.position)
		_shown_slot = slot
	_ghost.visible = true
	
	
func _build_edges(size: Vector3) -> ArrayMesh:
	var h := size / 2.0
	var vertices := PackedVector3Array([
		Vector3(-h.x, -h.y, -h.z), Vector3(h.x, -h.y, -h.z),
		Vector3(h.x, -h.y, h.z), Vector3(-h.x, -h.y, h.z),
		Vector3(-h.x, h.y, -h.z), Vector3(h.x, h.y, -h.z),
		Vector3(h.x, h.y, h.z), Vector3(-h.x, h.y, h.z),
	])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = EDGE_INDICES
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return mesh

func _make_material(box: BoxMesh) -> StandardMaterial3D:
	var color := (box.material as StandardMaterial3D).albedo_color
	color.a = ghost_alpha
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func nearest_slot_for(block: SortBlock) -> Slot:
	if block == null:
		return null
	var best: Slot = null
	var best_distance := snap_range
	for slot in _candidate_slots():
		if not slot.is_empty():
			continue
		var distance := slot.global_position.distance_to(block.global_position)
		if distance < best_distance:
			best_distance = distance
			best = slot
	return best

func _held_block() -> SortBlock:
	for block in block_row.blocks:
		if is_instance_valid(block) and block.is_picked_up() and not _is_in_slot(block):
			return block
	return null

func _is_in_slot(block: SortBlock) -> bool:
	for slot in _candidate_slots():
		if slot.block == block:
			return true
	return false

func _candidate_slots() -> Array[Slot]:
	var result: Array[Slot] = []
	for slot in block_row.slots:
		if slot.is_visible_in_tree():
			result.append(slot)
	result.append(block_row.temp_slot)
	return result
