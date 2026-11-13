## STILL NEED TO DOCUMENT 11/13/2026

class_name Slot
extends Node3D

signal block_placed(slot: Slot, block: SortBlock)
signal block_removed(slot: Slot, block: SortBlock)

const ZONE_RADIUS_FACTOR := 0.6
const PAD_FACTOR := 1.3
const PAD_THICKNESS := 0.01

@export var index: int = 0
@onready var snap_zone: XRToolsSnapZone = $SnapZone
@onready var pad_mesh: MeshInstance3D = $PadMesh

var block: SortBlock

func _ready() -> void:
	assert(snap_zone != null, "snap_zone reference is missing in Slot.gd!")
	snap_zone.snap_require = SortBlock.GROUP
	snap_zone.has_picked_up.connect(_on_has_picked_up)
	snap_zone.has_dropped.connect(_on_has_dropped)

func resize(unit: float) -> void:
	snap_zone.grab_distance = unit * ZONE_RADIUS_FACTOR
	var pad := BoxMesh.new()
	pad.size = Vector3(unit * PAD_FACTOR, PAD_THICKNESS, unit * PAD_FACTOR)
	pad_mesh.mesh = pad
	pad_mesh.position = Vector3(0.0, -PAD_THICKNESS / 2.0, 0.0)

func place(new_block: SortBlock) -> void:
	snap_zone.pick_up_object(new_block)

func is_empty() -> bool:
	return block == null

func _on_has_picked_up(what: Node3D) -> void:
	block = what as SortBlock
	block_placed.emit(self, block)

func _on_has_dropped() -> void:
	var removed := block
	block = null
	block_removed.emit(self, removed)
