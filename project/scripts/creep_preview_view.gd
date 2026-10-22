extends Node3D
## M0.5.2: extract actual (WinterTD-authored) GLB root translation.
## AnimationPlayer is advanced manually in physics ticks. The C++ fixture
## receives only the per-tick translation, and no longer invents velocity.
## The source Fox Walk clip is still available alongside Walk_RootMotion.
## Model visual scale 0.0185; GLB root translation values use source units.

const MODEL_SCALE: float = 0.0185

@onready var fox: Node3D = $FoxModel
@onready var bar_pivot: Node3D = $HealthRoot
@onready var bar_fill: MeshInstance3D = $HealthRoot/Fill

var mover: Node3D
var player: AnimationPlayer
var last_phase: int = -1
var walk_root_clip: StringName = &""
var idle_clip: StringName = &""
var root_motion_valid: bool = false
var root_motion_distance: float = 0.0


func _ready() -> void:
    mover = get_parent() as Node3D
    player = _find_animation_player(fox)
    if player == null:
        push_error("M0.5.2: GLB has no AnimationPlayer.")
        set_physics_process(false)
        return

    # No automatic playback in idle/render loop. One evaluation per physics tick.
    player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
    walk_root_clip = _find_clip("Walk_RootMotion")
    idle_clip = _find_clip("Survey")
    if walk_root_clip.is_empty() or idle_clip.is_empty():
        push_error("M0.5.2: Walk_RootMotion or Survey clip is missing: " +
            str(player.get_animation_list()))
        set_physics_process(false)
        return

    var animation := player.get_animation(walk_root_clip)
    var candidate_paths: Array[String] = []
    var strongest_delta: float = 0.0
    var motion_path := NodePath()
    for i in range(animation.get_track_count()):
        if animation.track_get_type(i) != Animation.TYPE_POSITION_3D:
            continue
        var path := animation.track_get_path(i)
        candidate_paths.append(String(path))
        var begin := animation.position_track_interpolate(i, 0.0)
        var end := animation.position_track_interpolate(i, animation.length)
        var horizontal_travel := Vector2(end.x - begin.x, end.z - begin.z).length()
        # The derived clip has 81+ source units of forward motion; ordinary
        # Fox hip bob has no net displacement. Works if Godot renames the node.
        if horizontal_travel > strongest_delta:
            strongest_delta = horizontal_travel
            motion_path = path

    if strongest_delta > 20.0:
        player.root_motion_track = motion_path
        root_motion_valid = true
    else:
        push_error("M0.5.2: No translating root track in imported Walk_RootMotion.")

    if not root_motion_valid:
        push_error("M0.5.2: Imported GLB lost its root-motion translation path. " +
            "Available position tracks: " + str(candidate_paths))
        set_physics_process(false)
        return

    # Loop the root-bearing animation, otherwise motion stops after 0.708s.
    # The root-motion API handles extraction across loop boundaries.
    animation.loop_mode = Animation.LOOP_LINEAR
    var survey := player.get_animation(idle_clip)
    if survey != null:
        survey.loop_mode = Animation.LOOP_LINEAR

    print("M0.5.2: Root-motion track: ", player.root_motion_track,
        " clip: ", walk_root_clip,
        " travel in source units: ", strongest_delta)


func _physics_process(delta: float) -> void:
    if player == null or not root_motion_valid:
        return
    if not mover.has_method("apply_demo_root_motion"):
        push_error("M0.5.2: Updated native GDExtension not loaded. Rebuild C++.")
        set_physics_process(false)
        return

    var phase: int = int(mover.call("get_demo_phase"))
    if phase != last_phase:
        last_phase = phase
        match phase:
            0:
                player.play(idle_clip)
            1:
                player.play(walk_root_clip)
            _:
                player.stop()

    if phase == 0 or phase == 1:
        player.advance(delta)
        if phase == 1:
            # Extracted root delta is in source GLB local units.
            # C++ owns the maze demo target and consumes only the distance.
            var model_delta: Vector3 = player.get_root_motion_position()
            var scaled_delta := Vector3(model_delta.x, 0.0, model_delta.z) * MODEL_SCALE
            root_motion_distance += scaled_delta.length()
            mover.call("apply_demo_root_motion", scaled_delta, delta)


func _process(_delta: float) -> void:
    if mover == null or not mover.has_method("get_demo_phase"):
        return

    var phase: int = int(mover.call("get_demo_phase"))
    var hp: float = clampf(float(mover.call("get_demo_health_fraction")), 0.0, 1.0)
    bar_fill.scale.x = maxf(0.005, hp)
    bar_fill.position.x = -0.85 * (1.0 - hp)

    var camera := get_viewport().get_camera_3d()
    if camera != null:
        bar_pivot.global_basis = camera.global_basis

    if phase == 2:
        # No licensed death clip in the Fox model: test-only collapse.
        var t: float = clampf(float(mover.call("get_demo_phase_seconds")) / 0.85, 0.0, 1.0)
        fox.rotation_degrees.z = 78.0 * t
        fox.position.y = -0.35 * t
    else:
        fox.rotation_degrees.z = 0.0
        fox.position.y = -0.006


func _find_clip(name_hint: String) -> StringName:
    for name in player.get_animation_list():
        if String(name).to_lower().contains(name_hint.to_lower()):
            return name
    return &""


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
