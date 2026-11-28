## BlockRow is a series of slots (and a temporary slot) that serve as the 
## physical representation of the array the sorting algorithm sorts.
class_name BlockRow
extends Node3D

## Spacing between two Slots.
const SPACING_FACTOR := 1.6

## animation settings
const RISE_DURATION := 0.45
const RISE_STAGGER := 0.08

## Array of [Slot] scenes.
@export var slots: Array[Slot] = []
## Temporary [Slot] representing the `temp` variable seen in many sorting 
## algorithms
@export var temp_slot: Slot
## The [PackedScene] that holds [SortBlock].tscn
@export var block_scene: PackedScene
## The maximum height that a [SortBlock] instance can have.
@export var max_block_height: float = 1.0

## The array of [SortBlock]s
var blocks: Array[SortBlock] = []
## A shallow, sorted copy of the [member slots] array.
var _ordered: Array[Slot] = []

## Sort the slots, ensure indices are correct
func _ready() -> void:
	_ordered = slots.duplicate()
	_ordered.sort_custom(func(a: Slot, b: Slot) -> bool: return a.index < b.index)
	for i in _ordered.size():
		assert(_ordered[i].index == i, "slot indices must be exactly 0 to N-1")
	temp_slot.index = Step.TEMP_SLOT

## Set up the [BlockRow] by creating its blocks [br]
## @param values The values of the blocks in the array
func setup(values: Array) -> void:
	var count := values.size()
	assert(count >= 1 and count <= _ordered.size(), "need 1 to %d values" % _ordered.size())
	clear()
	var active: Array[Slot] = []
	for i in count:
		active.append(_ordered[i])
	var footprint := _footprint(active, max_block_height / count)
	# Activate and resize all slots to their proper sizes
	for i in _ordered.size():
		_ordered[i].set_active(i < count)
		if i < count:
			_ordered[i].resize(footprint, max_block_height)
	temp_slot.resize(footprint, max_block_height)
	# Instantiate blocks onto the slots
	for i in count:
		var block := block_scene.instantiate() as SortBlock
		add_child(block)
		block.configure(values[i], count, max_block_height, footprint)
		block.global_position = active[i].global_position
		active[i].place(block)
		blocks.append(block)
		block.rise(RISE_DURATION, i * RISE_STAGGER)

## Proper getter for the slot at an index.  [br]
## @param slot_index 	Index of the slot	[br]
## @returns 			[Slot] 
func slot_for_index(slot_index: int) -> Slot:
	if slot_index == Step.TEMP_SLOT:
		return temp_slot
	return _ordered[slot_index]

## Calculates the maximum safe size (or "footprint") a [Slot] can have without 
## overlapping or crowding adjacent Slots. [br]
## @param active	the active slots in the [BlockRow] [br]
## @param unit		the amount of height added by increasing the value of a 
## 					block by 1. Equivalent to the maximum block height divided 
## 					by the number of blocks. [br]
## @returns			The footprint (maximum safe size) 
func _footprint(active: Array[Slot], unit: float) -> float:
	return minf(unit, slot_spacing(active.size()) / SPACING_FACTOR)

## Clear all slots and free (destroy) all blocks
func clear() -> void:
	for slot in _ordered:
		slot.clear()
		slot.set_active(false)
	temp_slot.clear()
	for block in blocks:
		block.queue_free()
	blocks.clear()

func slot_spacing(count: int) -> float:
	var nearest := INF
	for i in range(count - 1):
		nearest = minf(nearest, _ordered[i].global_position.distance_to(_ordered[i + 1].global_position))
	return nearest
