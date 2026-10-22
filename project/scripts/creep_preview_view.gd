extends Node3D
## Presentation-only adapter for the native C++ CreepDemoMover.
## The AnimationPlayer drives actual Fox.glb joint animations.
## Survey/Walk are from the GLB; there is no source death clip.

@onready var fox: Node3D = $FoxModel
@onready var bar_pivot: Node3D = $HealthRoot
@onready var bar_fill: MeshInstance3D = $HealthRoot/Fill

var mover: Node3D
var player: AnimationPlayer
var selected_clip: StringName = &""
var last_phase: int = -1


func _ready() -> void:
    mover = get_parent() as Node3D
    player = _find_animation_player(fox)
    if player == null:
        push_error("M0.5: Fox GLB imported without AnimationPlayer.")
    _update_view()


func _process(_delta: float) -> void:
    _update_view()


func _update_view() -> void:
    if mover == null or not mover.has_method("get_demo_phase"):
        return

    var phase: int = int(mover.call("get_demo_phase"))
    var fraction: float = clampf(float(mover.call("get_demo_health_fraction")), 0.0, 1.0)
    bar_fill.scale.x = maxf(0.005, fraction)
    bar_fill.position.x = -0.85 * (1.0 - fraction)

    var camera := get_viewport().get_camera_3d()
    if camera != null:
        bar_pivot.global_basis = camera.global_basis

    if phase != last_phase:
        last_phase = phase
        if phase == 0:
            _play_named("Survey")
        elif phase == 1:
            _play_named("Walk")
        elif player != null:
            player.stop()

    if phase == 2:
        # Explicit temporary visual collapse, NOT an imported death animation.
        var t: float = clampf(float(mover.call("get_demo_phase_seconds")) / 0.85, 0.0, 1.0)
        fox.rotation_degrees.z = 78.0 * t
        fox.position.y = -0.35 * t
    else:
        fox.rotation_degrees.z = 0.0
        fox.position.y = 0.0


func _play_named(keyword: String) -> void:
    if player == null:
        return
    for candidate in player.get_animation_list():
        var name := String(candidate)
        if name.to_lower().contains(keyword.to_lower()):
            if selected_clip == candidate and player.is_playing():
                return
            selected_clip = candidate
            var anim := player.get_animation(candidate)
            if anim != null:
                anim.loop_mode = Animation.LOOP_LINEAR
            player.play(candidate)
            return
    push_warning("M0.5: Missing animation clip: " + keyword)


func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var found := _find_animation_player(child)
        if found != null:
            return found
    return null


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.physical_keycode == KEY_H:
            mover.call("apply_demo_hit", 25)
        elif event.physical_keycode == KEY_R:
            mover.call("reset_demo")
