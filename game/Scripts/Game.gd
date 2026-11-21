## Sets up the XR interface.
extends Node3D

## The [XRInterface] for the game
var xr_interface: XRInterface

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Debugging signals
		var openxr := xr_interface as OpenXRInterface
		openxr.session_begun.connect(func(): print("session begun"))
		openxr.session_synchronized.connect(func(): print("session synchronized"))
		openxr.session_visible.connect(func(): print("session visible"))
		openxr.session_focussed.connect(func(): print("session focussed"))
		openxr.session_stopping.connect(func(): print("session stopping"))

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")
