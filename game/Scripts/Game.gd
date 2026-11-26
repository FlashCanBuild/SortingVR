## Sets up the XR interface.
extends Node3D

@export var origin: XROrigin3D
@export var settings_panel: FloatingPanel
@export var sorting_board: SortingBoard

var _base_origin_y := 0.0

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
	_base_origin_y = origin.position.y
	_connect_settings()

func _connect_settings() -> void:
	var settings := settings_panel.content as SettingsPanel
	assert(settings != null, "Game: the settings panel's content must be a SettingsPanel")
	settings.recenter_requested.connect(_on_recenter_requested)
	settings.height_offset_changed.connect(_on_height_offset_changed)
	settings.auto_move_toggled.connect(_on_auto_move_toggled)

func _on_recenter_requested() -> void:
	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)

func _on_height_offset_changed(offset: float) -> void:
	origin.position.y = _base_origin_y + offset

func _on_auto_move_toggled(enabled: bool) -> void:
	sorting_board.auto_move_loop_variables = enabled
	sorting_board.reset_run()
