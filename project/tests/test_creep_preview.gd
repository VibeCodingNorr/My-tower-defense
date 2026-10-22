extends SceneTree
## Headless M0.5 smoke test: imported rigged model, real clips and C++ HP fixture.

func _initialize() -> void:
    call_deferred("_verify")


func _fail(message: String) -> void:
    push_error("M0.5 test failed: " + message)
    quit(1)


func _find_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var candidate := _find_player(child)
        if candidate != null:
            return candidate
    return null


func _verify() -> void:
    var scene: PackedScene = load("res://scenes/preview_creep.tscn")
    if scene == null:
        _fail("Preview creep scene did not import.")
        return

    var mover: Node = scene.instantiate()
    root.add_child(mover)
    await process_frame

    if not mover.has_method("get_demo_phase") or not mover.has_method("apply_demo_hit"):
        _fail("Native CreepDemoMover methods unavailable.")
        return

    var fox: Node = mover.get_node_or_null("Presentation/FoxModel")
    if fox == null:
        _fail("Imported animated Fox model is missing.")
        return

    var player := _find_player(fox)
    if player == null:
        _fail("GLB did not import an AnimationPlayer.")
        return

    var clips := PackedStringArray()
    for entry in player.get_animation_list():
        clips.append(String(entry))
    var has_walk := false
    var has_survey := false
    for entry in clips:
        has_walk = has_walk or entry.to_lower().contains("walk")
        has_survey = has_survey or entry.to_lower().contains("survey")

    if not has_walk or not has_survey:
        _fail("Expected Walk and Survey clips, found: " + str(clips))
        return

    if not mover.has_method("get_demo_speed"):
        _fail("Native movement speed accessor is unavailable.")
        return

    mover.call("apply_demo_hit", 25)
    if int(mover.call("get_demo_health")) != 75:
        _fail("HP did not drop from 100 to 75.")
        return

    mover.call("apply_demo_hit", 75)
    if int(mover.call("get_demo_phase")) != 2:
        _fail("0 HP did not transition to demo death state.")
        return

    mover.call("reset_demo")
    if int(mover.call("get_demo_phase")) != 0 or int(mover.call("get_demo_health")) != 100:
        _fail("Reset did not restore idle and 100 HP.")
        return

    print("M0.5 smoke OK – animation clips: ", clips)
    quit(0)
