extends Node3D
## M0.4 preview-only art direction. No gameplay or navigation.
## Recolors tower surfaces per instance without editing the CC0 source GLBs.

const WINTER_TOWER_SHADER: Shader = preload("res://shaders/winter_tower_palette.gdshader")


func _ready() -> void:
    for scene_node in get_children():
        if String(scene_node.name).begins_with("BuildPad"):
            _apply_to_meshes(scene_node)


func _apply_to_meshes(node: Node) -> void:
    if node is MeshInstance3D:
        var model := node as MeshInstance3D
        if model.mesh != null:
            for index in range(model.mesh.get_surface_count()):
                var source := model.get_active_material(index) as BaseMaterial3D
                if source == null:
                    continue
                var winter_material := ShaderMaterial.new()
                winter_material.shader = WINTER_TOWER_SHADER
                winter_material.set_shader_parameter("source_tint", source.albedo_color)
                winter_material.set_shader_parameter("has_texture", source.albedo_texture != null)
                if source.albedo_texture != null:
                    winter_material.set_shader_parameter("source_texture", source.albedo_texture)
                model.set_surface_override_material(index, winter_material)
    for child in node.get_children():
        _apply_to_meshes(child)
