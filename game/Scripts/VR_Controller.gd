extends XRController3D

## grab_area is a region of 3D space that is looking for CollisionBodies to grab
@onready var grab_area: Area3D = $Area
## grab_raycast is a raycast that looks for a CollisionBody to grab
@onready var grab_raycast: RayCast3D = $GrabCast
## grab_pos_node is the position where held objects stay.
## [jag329] Marker3D is a editor-only extension of a Node3D that displays a 
## crosshair/marker in the 3D editor for visual clarity.
@onready var grab_pos_node: Marker3D = $Grab_Pos
## hand-mesh is the 3D mesh of the hand
@onready var hand_mesh: MeshInstance3D = $Hand
## teleport_raycast is a raycast that is used to teleport the player around
@onready var teleport_raycast: RayCast3D = $RayCast
## The origin point in AR/VR.
@onready var xr_origin := get_parent() as XROrigin3D
 
## The velocity the controller is moving at. We will calculate this by changes in
## position every physics frame.
var controller_velocity := Vector3.ZERO
## The controller’s previous position. We will use this to calculate the 
## controller’s velocity.
var prior_controller_position := Vector3.ZERO
## The last 30 calculated velocities (1/3 of a second worth of velocities, 
## assuming the game is running at 90 FPS).
var prior_controller_velocities: Array[Vector3] = []

## The currently-held object, a RigidBody, if there is one.
var held_object: RigidBody3D = null
## The data of the currently-held object, used to reset the object when it is no
## longer being held.
# [jag329] this may need to change later? When the blocks that we make for 
# sorting require more data.
var held_object_data := {
	"freeze": false,
	"freeze_mode": RigidBody3D.FREEZE_MODE_STATIC,
	"layer": 1,
	"mask": 1,
}

var grab_mode := "AREA"
## The position at which the teleport Raycast is aimed.
var teleport_pos: Variant = null  # Vector3 or null
## The mesh used to represent the teleport position.
var teleport_mesh: Node3D
## A variable for tracking whether the teleport button is being held down or not.
var teleport_button_down := false

# [jag329] exporting these two variables as they may want to be changed later.
## The dead zone for both the trackpad and the joystick.
@export var CONTROLLER_DEADZONE := 0.65
## The speed the player moves at when moving using the trackpad and/or the joystick.
@export var MOVEMENT_SPEED := 1.5
## Throwing frames (number of frames to average velocity on)
@export var THROWING_FRAMES := 10

## A boolean to track whether the player is moving using this controller.
var directional_movement := false

# Action names must match your OpenXR action map
# (these are the names in Godot's default action map).
const ACTION_TELEPORT := "trigger_click"
const ACTION_GRAB := "grip_click"
const ACTION_MODE_SWITCH := "menu_button"
const ACTION_MOVE := "primary"  # thumbstick / trackpad Vector2


func _ready() -> void:
	
	# to add next time [11/7/2026]
	# if THROWING_FRAMES <= 0:
		
	# We need the teleport mesh to be separate from the controller, so moving 
	# and rotating the controller does not affect the position and rotation of 
	# the teleportation mesh.
	teleport_mesh = get_tree().root.get_node("Game/Teleport_Mesh")
	teleport_button_down = false
	# We set the default grab mode to AREA so it uses the Area node to grab 
	# objects by default.
	grab_mode = "AREA"
	$Sleep_Area.body_entered.connect(_on_sleep_area_entered)
	$Sleep_Area.body_exited.connect(_on_sleep_area_exited)
	button_pressed.connect(_on_button_pressed)
	button_released.connect(_on_button_released)

func _physics_process(delta: float) -> void:
	# If the teleport button is down, attempt a teleport
	if teleport_button_down:
		teleport_raycast.force_raycast_update()
		# We check if the normal's Y is >= 0.85 because this allows the player 
		# only to teleport on fairly flat faces pointing upwards.
		if teleport_raycast.is_colliding() and teleport_raycast.get_collider() is StaticBody3D and teleport_raycast.get_collision_normal().y >= 0.85:
			teleport_pos = teleport_raycast.get_collision_point()
			teleport_mesh.global_transform.origin = teleport_pos
	
	# If the controller is active (there is a controller and it is being tracked)
	if get_is_active():
		# We add all of the prior velocity calculations in prior_controller_velocities 
		# to controller_velocity. By using the prior calculations, we get a 
		# smoother throwing/catching experience, although it is not perfect. 
		# We want to get the average of these velocities, as otherwise we’d get 
		# crazy high velocity numbers that are not realistic.
		var sampled_velocity := (global_transform.origin - prior_controller_position) / delta
		var controller_pose := get_pose()
		if controller_pose and controller_pose.has_tracking_data and controller_pose.linear_velocity != Vector3.ZERO:
			sampled_velocity = xr_origin.global_transform.basis * controller_pose.linear_velocity
		prior_controller_position = global_transform.origin

		prior_controller_velocities.append(sampled_velocity)
		if prior_controller_velocities.size() > THROWING_FRAMES:
			prior_controller_velocities.remove_at(0)

		var total := Vector3.ZERO
		for vel in prior_controller_velocities:
			total += vel
		controller_velocity = total / prior_controller_velocities.size()
			
	if held_object:
		# Update held object data
		var held_scale := held_object.scale
		held_object.global_transform = grab_pos_node.global_transform
		held_object.scale = held_scale
		
	# In Godot 4 the OpenXR action map abstracts the hardware, so there is
	# one Vector2 action instead of separate trackpad/joystick axes.
	var move_input := get_vector2(ACTION_MOVE)  # x = right, y = forward
	if move_input.length() < CONTROLLER_DEADZONE:
		move_input = Vector2.ZERO
	else:
		move_input = move_input.normalized() * ((move_input.length() - CONTROLLER_DEADZONE) / (1.0 - CONTROLLER_DEADZONE))
	var camera := get_parent().get_node("Player_Camera") as Node3D
	var forward_direction := -camera.global_transform.basis.z.normalized()
	var right_direction := camera.global_transform.basis.x.normalized()
	var movement_vector := move_input.normalized()
	var movement_forward := forward_direction * movement_vector.y * delta * MOVEMENT_SPEED
	var movement_right := right_direction * movement_vector.x * delta * MOVEMENT_SPEED
	movement_forward.y = 0
	movement_right.y = 0
	if movement_right.length() > 0 or movement_forward.length() > 0:
		get_parent().global_translate(movement_right + movement_forward)
		directional_movement = true
	else:
		directional_movement = false


func _on_button_pressed(button_name: String) -> void:
	# Trigger
	if button_name == ACTION_TELEPORT:
		if held_object:
			if held_object.has_method("interact"):
				held_object.interact()
		else:
			if not teleport_mesh.visible:
				teleport_button_down = true
				teleport_mesh.visible = true
				teleport_raycast.visible = true
	if button_name == ACTION_GRAB:
		if teleport_button_down:
			return
		if not held_object:
			var rigid_body: RigidBody3D = null
			if grab_mode == "AREA":
				for body in grab_area.get_overlapping_bodies():
					if body is RigidBody3D and not "NO_PICKUP" in body:
						rigid_body = body
						break
			elif grab_mode == "RAYCAST":
				grab_raycast.force_raycast_update()
				if grab_raycast.is_colliding():
					var collider := grab_raycast.get_collider()
					if collider is RigidBody3D and not "NO_PICKUP" in collider:
						rigid_body = collider
			if rigid_body:
				held_object = rigid_body
				held_object_data["freeze"] = held_object.freeze
				held_object_data["freeze_mode"] = held_object.freeze_mode
				held_object_data["layer"] = held_object.collision_layer
				held_object_data["mask"] = held_object.collision_mask
				held_object.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
				held_object.freeze = true
				held_object.collision_layer = 0
				held_object.collision_mask = 0
				hand_mesh.visible = false
				grab_raycast.visible = false
				if held_object.has_method("picked_up"):
					held_object.picked_up()
				if "controller" in held_object:
					held_object.controller = self

		else:
			held_object.freeze = held_object_data["freeze"]
			held_object.freeze_mode = held_object_data["freeze_mode"]
			held_object.collision_layer = held_object_data["layer"]
			held_object.collision_mask = held_object_data["mask"]
			held_object.apply_impulse(controller_velocity)
			if held_object.has_method("dropped"):
				held_object.dropped()
			if "controller" in held_object:
				held_object.controller = null
			held_object = null
			hand_mesh.visible = true
			if grab_mode == "RAYCAST":
				grab_raycast.visible = true

		$AudioStreamPlayer3D.play()

	# Menu button: toggle grab mode
	if button_name == ACTION_MODE_SWITCH:
		if grab_mode == "AREA":
			grab_mode = "RAYCAST"
			if not held_object:
				grab_raycast.visible = true
		elif grab_mode == "RAYCAST":
			grab_mode = "AREA"
			grab_raycast.visible = false


func _on_button_released(button_name: String) -> void:
	if button_name == ACTION_TELEPORT:
		if teleport_button_down:
			if teleport_pos != null and teleport_mesh.visible:
				var parent := get_parent() as Node3D
				var camera := parent.get_node("Player_Camera") as Node3D
				var camera_offset := camera.global_transform.origin - parent.global_transform.origin
				camera_offset.y = 0
				parent.global_transform.origin = teleport_pos - camera_offset

			teleport_button_down = false
			teleport_mesh.visible = false
			teleport_raycast.visible = false
			teleport_pos = null

func _on_sleep_area_entered(body: Node3D) -> void:
	if "can_sleep" in body:
		body.can_sleep = false
		body.sleeping = false


func _on_sleep_area_exited(body: Node3D) -> void:
	if "can_sleep" in body:
		body.can_sleep = true
