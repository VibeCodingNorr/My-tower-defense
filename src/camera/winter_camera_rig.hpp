#pragma once

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/input_event.hpp>

namespace godot {
class WinterCameraRig final : public Node3D {
    GDCLASS(WinterCameraRig, Node3D)

public:
    void _ready() override;
    void _process(double delta) override;
    void _unhandled_input(const Ref<InputEvent> &event) override;

protected:
    static void _bind_methods();

private:
    Node3D *pitch_pivot_ = nullptr;
    Camera3D *camera_ = nullptr;
    double yaw_degrees_ = 0.0;
    double target_distance_ = 42.0;
    double current_distance_ = 42.0;
};
} // namespace godot
