## IndexSlider is a single interactable slider linked to an "index variable", 
## which is a variable whose value corresponds to an index in the array the user
## is tasked to sort. During a [SetAction], a player will set one of these 
## variables to an index in the array by physically moving the slider.
class_name IndexSlider
extends Node3D

## Signal to emit upon the handle landing on a particular index
signal released_at(slider: IndexSlider, index: int)
## Distance between the label and the physical slider
const LABEL_MARGIN := 0.125

## The interactable slider
@export var slider: XRToolsInteractableSlider
## The slider's handle that points to an index in the array
@export var handle: XRToolsInteractableHandle
## The name of the variable (e.g. i, j, minIndex)
@export var name_label: Label3D
## Pointer's mesh
@export var pointer_mesh: MeshInstance3D

## The variable this slider corresponds to
var variable: Variable
## (Unsure what this is for yet, come back to this)
var committed: int = Variable.UNDEFINED
## Distance between the slider "notches" (positive stops where the handle snaps 
## to)
var _step: float = 0.0

const SNAP_TIME := 0.15

## Tween animation variables
var _locked: bool = false
var _snapping: bool = false
var _tween: Tween

func _ready() -> void:
	## Connect the slider's release signal to the _on_released 
	slider.released.connect(_on_released)

## Configure the IndexSlider's fields[br]
## @param new_variable	the variable in which to track with this slider[br]
## @param count			the total number of elements in the array we're sorting[br]
## @param step			the physical distance between two indices[br]
## @param auto_move		whether or not this slider should automatically move 
## 						upon being set
func configure(new_variable: Variable, count: int, step: float, auto_move: bool) -> void:
	variable = new_variable
	name_label.modulate = variable.color
	_tint_pointer(variable.color)
	_step = step
	_locked = variable.loop_controlled and auto_move
	name_label.text = str(variable.name)
	name_label.position.x = -step - LABEL_MARGIN
	slider.slider_steps = 0.0
	slider.slider_limit_min = -step
	slider.slider_limit_max = (count - 1) * step
	show_index(Variable.UNDEFINED)

func show_index(index: int) -> void:
	_stop_snap()
	committed = index
	slider.slider_position = index * _step

func commit(index: int) -> void:
	committed = index
	_snap_to(index)

func revert() -> void:
	slider.slider_position = committed * _step

func _on_released(_interactable) -> void:
	var index := roundi(slider.slider_position / _step)
	if index == committed:
		_snap_to(committed)
		return
	released_at.emit(self, index)
	
func _snap_to(index: int) -> void:
	_stop_snap()
	_snapping = true
	_refresh_grab()
	_tween = create_tween()
	_tween.tween_property(slider, "slider_position", index * _step, SNAP_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.finished.connect(_on_snap_finished)

func _stop_snap() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_snapping = false
	_refresh_grab()

func _on_snap_finished() -> void:
	_snapping = false
	_refresh_grab()

func _refresh_grab() -> void:
	handle.enabled = not (_locked or _snapping)
	
func _tint_pointer(color: Color) -> void:
	assert(pointer_mesh.mesh is PrimitiveMesh, "IndexSlider: the pointer needs a primitive mesh")
	var mesh := pointer_mesh.mesh.duplicate(true) as PrimitiveMesh
	assert(mesh.material is StandardMaterial3D, "IndexSlider: the pointer mesh needs a StandardMaterial3D")
	(mesh.material as StandardMaterial3D).albedo_color = color
	pointer_mesh.mesh = mesh
