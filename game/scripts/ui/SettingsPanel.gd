class_name SettingsPanel
extends PanelContainer

signal recenter_requested
signal height_offset_changed(offset: float)
signal auto_move_toggled(enabled: bool)

const HEIGHT_STEP := 0.02
const HEIGHT_LIMIT := 0.5

@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var auto_move_check: CheckButton
@export var height_label: Label
@export var height_down_button: Button
@export var height_up_button: Button
@export var recenter_button: Button

var _height_offset := 0.0

func _ready() -> void:
	_setup_volume_slider(music_slider, &"Music")
	_setup_volume_slider(sfx_slider, &"SFX")
	auto_move_check.toggled.connect(auto_move_toggled.emit)
	height_down_button.pressed.connect(_on_height_step.bind(-HEIGHT_STEP))
	height_up_button.pressed.connect(_on_height_step.bind(HEIGHT_STEP))
	recenter_button.pressed.connect(recenter_requested.emit)
	_refresh_height_label()

func _setup_volume_slider(slider: HSlider, bus_name: StringName) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	assert(bus != -1, "SettingsPanel: no audio bus named %s" % bus_name)
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus))
	slider.value_changed.connect(_on_volume_changed.bind(bus))

func _on_volume_changed(value: float, bus: int) -> void:
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	AudioServer.set_bus_mute(bus, is_zero_approx(value))

func _on_height_step(delta: float) -> void:
	_height_offset = clampf(_height_offset + delta, -HEIGHT_LIMIT, HEIGHT_LIMIT)
	_refresh_height_label()
	height_offset_changed.emit(_height_offset)

func _refresh_height_label() -> void:
	height_label.text = "%+d cm" % roundi(_height_offset * 100.0)
