## CompareStep represents a comparison step within a sorting algorithm.
## We compare two indices - slot a and slot b - and present an expected 
## result (true/false).
## In the context of this game, this means two boxes are highlighted, 
## and the user needs to press either the TRUE button or the FALSE button.
class_name CompareStep
extends Step

## The index of the first slot
var slot_a: int
## The index of the second slot
var slot_b: int
## The expected result of the comparison (true/false)
var expected: bool
## Whether this counts as a comparison in the sorting statistics
var counts_as_comparison: bool

## Initialize the CompareStep[br]
## @param a			the first slot's index[br]
## @param b			the second slot's index[br]
## @param answer	the correct answer to the step[br]
## @param counts	whether it counts as a comparison[br]
func _init(pseudocode_line: int, a: int, b: int, answer: bool, counts: bool = true) -> void:
	super(pseudocode_line)
	slot_a = a
	slot_b = b
	expected = answer
	counts_as_comparison = counts

## Whether or not a given [PlayerAction] satisfies the CompareStep (see [CompareAction])
## @param action The player's action to check
func is_satisfied_by(action: PlayerAction) -> bool:
	var answer_action := action as CompareAction
	return answer_action != null and answer_action.answer == expected
