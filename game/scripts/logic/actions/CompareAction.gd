## Player action to represent a COMPARE button press (TRUE/FALSE buttons).
class_name CompareAction
extends PlayerAction
 
## Reflects which button was pressed (TRUE/FALSE).
var answer: bool
 
## Constructor: sets [member answer] to `value`.[br]
## @param value The corresponding value of the CompareAction
func _init(value: bool) -> void:
	answer = value
