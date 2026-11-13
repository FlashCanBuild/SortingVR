# CompareStep represents a comparison step within a sorting algorithm.
# We compare two indices - slot a and slot b - and present an expected 
# result (true/false).
# In the context of this game, this means two boxes are highlighted, 
# and the user needs to press either the TRUE button or the FALSE button.

class_name CompareStep
extends Step

var slot_a: int
var slot_b: int
var expected: bool
var counts_as_comparison: bool

func _init(pseudocode_line: int, a: int, b: int, answer: bool, counts: bool = true) -> void:
	super(pseudocode_line)
	slot_a = a
	slot_b = b
	expected = answer
	counts_as_comparison = counts

func is_satisfied_by(action: PlayerAction) -> bool:
	var answer_action := action as AnswerAction
	return answer_action != null and answer_action.answer == expected
