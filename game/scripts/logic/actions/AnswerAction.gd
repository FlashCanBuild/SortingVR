## Player action to represent a COMPARE button press (TRUE/FALSE buttons).
## The `answer` field reflects which button was pressed (TRUE/FALSE).

class_name AnswerAction
extends PlayerAction
 
var answer: bool
 
func _init(value: bool) -> void:
	answer = value
