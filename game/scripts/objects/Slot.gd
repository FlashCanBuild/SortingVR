## Slot is a location where a [SortBlock] can be placed. It represents an 
## individual index in an array.[br]
## Our Slots consist of a pad ([MeshInstance3D]) and a SnapZone ([XRToolsSnapZone]).
class_name Slot
extends Node3D

## Signal to send when a block is placed on this slot[br]
## @param slot		This slot[br]
## @param block		The block that was placed on this slot
signal block_placed(slot: Slot, block: SortBlock)

## Signal to send when a block is removed from this slot[br]
## @param slot		This slot[br]
## @param block		The block that was removed from this slot
signal block_removed(slot: Slot, block: SortBlock)

## The radius of the snap zone
const ZONE_RADIUS_FACTOR := 0.6
## The width/length of the square pad
const PAD_FACTOR := 1.3
## The thickness of the pad
const PAD_THICKNESS := 0.01

## This slot's "index" in the array
@export var index: int = 0
## The slot's snap zone
@export var snap_zone: XRToolsSnapZone
## The mesh for the slot's "pad"
@export var pad_mesh: MeshInstance3D
## The snap zone's collision box
@export var zone_box: CollisionShape3D

## The [SortBlock] that may or may not be on the Slot
var block: SortBlock

func _ready() -> void:
	snap_zone.has_picked_up.connect(_on_has_picked_up)
	snap_zone.has_dropped.connect(_on_has_dropped)

## Resizes the pad to fit the specification factors[br]
## @param footprint			the maximum safe size (or "footprint") a [Slot] can  
## 							have without overlapping or crowding adjacent Slots.
## 							[br]
## @param column_height		the desired height of [member zone_box].
func resize(footprint: float, column_height: float) -> void:
	assert(pad_mesh.mesh is BoxMesh, "Slot: the pad node needs a BoxMesh")
	assert(zone_box.shape is BoxShape3D, "Slot: the zone box node needs a BoxShape3D")
	snap_zone.grab_distance = footprint * ZONE_RADIUS_FACTOR
	var pad := pad_mesh.mesh.duplicate(true) as BoxMesh
	pad.size = Vector3(footprint * PAD_FACTOR, PAD_THICKNESS, footprint * PAD_FACTOR)
	pad_mesh.mesh = pad
	var column := zone_box.shape.duplicate(true) as BoxShape3D
	column.size = Vector3(footprint * PAD_FACTOR, column_height, footprint * PAD_FACTOR)
	zone_box.shape = column
	zone_box.position = Vector3(0.0, column_height / 2.0, 0.0)

## Set this Slot to be "active", meaning it is visible and [SortBlock]s can be snapped to its 
## [member snap_zone].[br]
## @param active	whether or not this Slot should be active (t/f)
func set_active(active: bool) -> void:
	visible = active
	snap_zone.enabled = active

## Place a block on this Slot
## @param new_block 	The [SortBlock] to place on this Slot
func place(new_block: SortBlock) -> void:
	snap_zone.pick_up_object(new_block)

## Clear the Slot of its contents (doing so will destroy this Slot's 
## [SortBlock], if it has one)
func clear() -> void:
	snap_zone.drop_object()
	block = null

## Whether or not the Slot is empty
func is_empty() -> bool:
	return not is_instance_valid(block)

## Wrapper signal to cast [XRToolsSnapZone]'s `has_picked_up` to a SortBlock.
func _on_has_picked_up(what: Node3D) -> void:
	print("f", Engine.get_process_frames(), " slot ", index, " picked up ", (what as SortBlock).value)
	block = what as SortBlock
	block_placed.emit(self, block)

## Wrapper signal to cast [XRToolsSnapZone]'s `has_dropped` to a SortBlock.
func _on_has_dropped() -> void:
	print("f", Engine.get_process_frames(), " slot ", index, " dropped ", block.value if block != null else "none")
	var removed := block
	block = null
	block_removed.emit(self, removed)
