## STILL NEED TO DOCUMENT 11/13/2026

class_name BlockRow
extends Node3D

const SPACING_FACTOR := 1.6

@export var slot_scene: PackedScene
@export var block_scene: PackedScene
@export var temp_slot: Slot
@export var max_block_height: float = 1.0

var slots: Array[Slot] = []
var blocks: Array[SortBlock] = []

func setup(values: Array) -> void:
	_clear()
	var count := values.size()
	var unit := max_block_height / count
	var spacing := unit * SPACING_FACTOR
	var start_x := -spacing * (count - 1) / 2.0
	temp_slot.index = Step.TEMP_SLOT
	temp_slot.resize(unit)
	for i in count:
		var slot := slot_scene.instantiate() as Slot
		slot.index = i
		add_child(slot)
		slot.position = Vector3(start_x + spacing * i, 0.0, 0.0)
		slot.resize(unit)
		slots.append(slot)
	for i in count:
		var block := block_scene.instantiate() as SortBlock
		add_child(block)
		block.configure(values[i], count, max_block_height)
		block.global_position = slots[i].global_position
		slots[i].place(block)
		blocks.append(block)

func slot_for_index(slot_index: int) -> Slot:
	if slot_index == Step.TEMP_SLOT:
		return temp_slot
	return slots[slot_index]

func _clear() -> void:
	for slot in slots:
		slot.queue_free()
	for block in blocks:
		block.queue_free()
	slots.clear()
	blocks.clear()
