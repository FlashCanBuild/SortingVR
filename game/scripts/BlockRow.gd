class_name BlockRow
extends Node3D

const SPACING_FACTOR := 1.6

@export var slots: Array[Slot] = []
@export var temp_slot: Slot
@export var block_scene: PackedScene
@export var max_block_height: float = 1.0

var blocks: Array[SortBlock] = []

var _ordered: Array[Slot] = []

func _ready() -> void:
	_ordered = slots.duplicate()
	_ordered.sort_custom(func(a: Slot, b: Slot) -> bool: return a.index < b.index)
	for i in _ordered.size():
		assert(_ordered[i].index == i, "slot indices must be exactly 0 to N-1")
	temp_slot.index = Step.TEMP_SLOT

func setup(values: Array) -> void:
	var count := values.size()
	assert(count >= 1 and count <= _ordered.size(), "need 1 to %d values" % _ordered.size())
	_clear()
	var active: Array[Slot] = []
	for i in count:
		active.append(_ordered[i])
	var unit := max_block_height / count
	var footprint := _footprint(active, unit)
	for i in _ordered.size():
		_ordered[i].set_active(i < count)
		if i < count:
			_ordered[i].resize(footprint)
	temp_slot.resize(footprint)
	for i in count:
		var block := block_scene.instantiate() as SortBlock
		add_child(block)
		block.configure(values[i], count, max_block_height, footprint)
		block.global_position = active[i].global_position
		active[i].place(block)
		blocks.append(block)

func slot_for_index(slot_index: int) -> Slot:
	if slot_index == Step.TEMP_SLOT:
		return temp_slot
	return _ordered[slot_index]

func _footprint(active: Array[Slot], unit: float) -> float:
	var nearest := INF
	for i in range(active.size() - 1):
		nearest = minf(nearest, active[i].global_position.distance_to(active[i + 1].global_position))
	return minf(unit, nearest / SPACING_FACTOR)

func _clear() -> void:
	for slot in _ordered:
		slot.clear()
	temp_slot.clear()
	for block in blocks:
		block.queue_free()
	blocks.clear()
