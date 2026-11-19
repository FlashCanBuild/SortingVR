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
	var mat := button_mesh.get_active_material(0) as StandardMaterial3D
	# Create a new StandardMaterial3D if none exists, or duplicate it so buttons don't share colors
	if mat == null:
		mat = StandardMaterial3D.new()
	else:
		mat = mat.duplicate() as StandardMaterial3D
	mat.albedo_color = color
	button_mesh.set_surface_override_material(0, mat)
	label.text = buttonText
