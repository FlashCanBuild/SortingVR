extends ColorRect

var controller_one
var controller_two

func _ready():
	# We wait four frame to ensure the VR interface is ready and going.
	for i in 4:
		await get_tree().process_frame

	var interface = XRServer.primary_interface
	
	# size the vignette to the XR interface
	size = interface.get_render_target_size()
	position = Vector2(0, 0)

	controller_one = get_parent().get_node("Left_Controller")
	controller_two = get_parent().get_node("Right_Controller")

	# invisible by default
	visible = false

func _process(delta):
	if not controller_one or not controller_two:
		return
	# vignette only visible during locomotion
	if controller_one.directional_movement or controller_two.directional_movement:
		visible = true
	else:
		visible = false
