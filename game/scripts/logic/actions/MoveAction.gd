## Player action to represent a MOVE action. Moving a block from `from_slot` to 
## `to_slot`.

class_name MoveAction
extends PlayerAction
 
var from_slot: int
var to_slot: int
 
func _init(source: int, target: int) -> void:
	from_slot = source
	to_slot = target
