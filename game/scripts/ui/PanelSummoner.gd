class_name PanelSummoner
extends Node

@export var controller: XRController3D
@export var pointer: XRToolsFunctionPointer
@export var camera: XRCamera3D
@export var summon_distance := 0.5
@export var summon_speed := 6.0
@export var pickup: XRToolsFunctionPickup
@export var grip_action: StringName = &"grip_click"

var _locked: FloatingPanel

func _physics_process(delta: float) -> void:
	if not controller.is_button_pressed(grip_action) or pickup.picked_up_object != null:
		_locked = null
		return
	_pull_toward_player(_locked, delta)

func _panel_from(node: Node) -> FloatingPanel:
	while node != null:
		if node is FloatingPanel:
			return node as FloatingPanel
		node = node.get_parent()
	return null

func _pull_toward_player(panel: FloatingPanel, delta: float) -> void:
	var cam := camera.global_transform
	var goal := cam.origin - cam.basis.z * summon_distance
	var weight := 1.0 - exp(-summon_speed * delta)
	panel.linear_velocity = Vector3.ZERO
	panel.angular_velocity = Vector3.ZERO
	panel.global_position = panel.global_position.lerp(goal, weight)
	var facing := Basis.looking_at(cam.origin - panel.global_position, Vector3.UP, true)
	panel.global_basis = panel.global_basis.orthonormalized().slerp(facing, weight)
