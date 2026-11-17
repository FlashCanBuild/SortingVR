## Player action to represent a MOVE action. Moving a block from 
## [member from_slot] to  [member to_slot].
class_name MoveAction
extends PlayerAction

## Index we're moving FROM
var from_slot: int
## Index we're moving TO
var to_slot: int
 
func _init(source: int, target: int) -> void:
	from_slot = source
	to_slot = target
