## MoveStep represents moving a block (a value) from one slot (index) to another.[br]
## Ex: move a block from slot 1 to slot 2.
class_name MoveStep
extends Step

## Index we're moving FROM
var from_slot: int
## Index we're moving TO
var to_slot: int

func _init(pseudocode_line: int, from: int, to: int) -> void:
	super(pseudocode_line)
	from_slot = from
	to_slot = to

## Whether or not a given [PlayerAction] satisfies the MoveStep (see [MoveAction])
## @param action The player's action to check
func is_satisfied_by(action: PlayerAction) -> bool:
	var move_action := action as MoveAction
	return move_action != null and move_action.from_slot == from_slot and move_action.to_slot == to_slot
