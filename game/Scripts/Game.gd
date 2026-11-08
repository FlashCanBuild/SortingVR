## Game.gd handles the Godot-to-VR interaction, as well as other globals

extends Node3D

func _ready() -> void:
	var xr_interface := XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized")
		# Ensure VSYNC is disabled - so computer monitor does not drag down FPS
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, check headset and runtime")
