extends MeshInstance3D

# Makes a new material and uses the SubViewport (called GUI) texture
# as the texture for this MeshInstance3D.

func _ready() -> void:
	# Get the SubViewport and wait two frames
	var viewport: SubViewport = get_node("GUI")
	await get_tree().process_frame
	await get_tree().process_frame

	# Get the texture
	var gui_img: ViewportTexture = viewport.get_texture()

	# Make a new material, set the viewport texture as its albedo texture,
	# then apply it to this mesh.
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = gui_img
	set_surface_override_material(0, material)
