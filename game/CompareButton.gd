## CompareButton is a "wrapper" button class that utilizes XRTools' 
## [XRToolsInteractableAreaButton] to allow the user to execute a 
## [CompareAction].
class_name CompareButton
extends Node3D

## Whether this button is a TRUE or FALSE button.
@export var compareType: bool;
## Text to show up on top of the button (e.g. TRUE, FALSE)
@export var buttonText: String;
## Color of the button
@export var color: Color

## The instance of [XRToolsInteractableAreaButton]
@onready var button_interact = $XRToolsInteractableAreaButton
## The instance of [MeshInstance3D] representing the pressable part of the button
@onready var button_mesh = $XRToolsInteractableAreaButton/Button
## The instance of [Label3D] that shows text on the button
@onready var label = $XRToolsInteractableAreaButton/Label3D

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	(button_mesh.get_active_material() as StandardMaterial3D).albedo_color = color
	label.text = buttonText
