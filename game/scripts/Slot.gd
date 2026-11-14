class_name Slot
extends Node3D

signal block_placed(slot: Slot, block: SortBlock)
signal block_removed(slot: Slot, block: SortBlock)

const ZONE_RADIUS_FACTOR := 0.6
const PAD_FACTOR := 1.3
const PAD_THICKNESS := 0.01

@export var index: int = 0
@export var snap_zone: XRToolsSnapZone
@export var pad_mesh: MeshInstance3D

var block: SortBlock

func _ready() -> void:
	snap_zone.snap_require = SortBlock.GROUP
	snap_zone.has_picked_up.connect(_on_has_picked_up)
	snap_zone.has_dropped.connect(_on_has_dropped)

func resize(footprint: float) -> void:
	assert(pad_mesh.mesh is BoxMesh, "Slot: the pad node needs a BoxMesh")
	snap_zone.grab_distance = footprint * ZONE_RADIUS_FACTOR
	var pad := pad_mesh.mesh.duplicate(true) as BoxMesh
	pad.size = Vector3(footprint * PAD_FACTOR, PAD_THICKNESS, footprint * PAD_FACTOR)
	pad_mesh.mesh = pad

func set_active(active: bool) -> void:
	visible = active
	snap_zone.enabled = active

func place(new_block: SortBlock) -> void:
	snap_zone.pick_up_object(new_block)

func clear() -> void:
	snap_zone.drop_object()
	block = null

func is_empty() -> bool:
	return not is_instance_valid(block)

func _on_has_picked_up(what: Node3D) -> void:
	block = what as SortBlock
	block_placed.emit(self, block)

func _on_has_dropped() -> void:
	var removed := block
	block = null
	block_removed.emit(self, removed)
