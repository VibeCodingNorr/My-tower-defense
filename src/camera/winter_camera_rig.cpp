#include "winter_camera_rig.hpp"

#include <algorithm>

#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_mouse_button.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>
#include <godot_cpp/core/memory.hpp>
#include <godot_cpp/classes/global_constants.hpp>

using namespace godot;

void WinterCameraRig::_bind_methods() {}

void WinterCameraRig::_ready() {
    pitch_pivot_ = memnew(Node3D);
    pitch_pivot_->set_name("PitchPivot");
    add_child(pitch_pivot_);
    pitch_pivot_->set_rotation_degrees(Vector3(-62.0, 0.0, 0.0));

    camera_ = memnew(Camera3D);
    camera_->set_name("RTSCamera");
    pitch_pivot_->add_child(camera_);
    camera_->set_position(Vector3(0.0, 0.0, current_distance_));
    camera_->set_fov(46.0);
    camera_->set_near(0.1);
    camera_->set_far(250.0);
    camera_->make_current();

    set_rotation_degrees(Vector3(0.0, yaw_degrees_, 0.0));
    set_process(true);
    set_process_unhandled_input(true);
}

void WinterCameraRig::_process(double delta) {
    const Input *input = Input::get_singleton();
    Vector3 movement;
    if (input->is_physical_key_pressed(KEY_W) || input->is_physical_key_pressed(KEY_UP)) {
        movement.z -= 1.0;
    }
    if (input->is_physical_key_pressed(KEY_S) || input->is_physical_key_pressed(KEY_DOWN)) {
        movement.z += 1.0;
    }
    if (input->is_physical_key_pressed(KEY_A) || input->is_physical_key_pressed(KEY_LEFT)) {
        movement.x -= 1.0;
    }
    if (input->is_physical_key_pressed(KEY_D) || input->is_physical_key_pressed(KEY_RIGHT)) {
        movement.x += 1.0;
    }

    // Node3D is yaw-only, so translating locally stays parallel to the ground.
    if (movement.length_squared() > 0.0) {
        const double speed = 17.0 * (current_distance_ / 42.0);
        translate_object_local(movement.normalized() * speed * delta);
    }

    if (input->is_physical_key_pressed(KEY_Q)) {
        yaw_degrees_ -= 85.0 * delta;
    }
    if (input->is_physical_key_pressed(KEY_E)) {
        yaw_degrees_ += 85.0 * delta;
    }
    set_rotation_degrees(Vector3(0.0, yaw_degrees_, 0.0));

    if (input->is_physical_key_pressed(KEY_SPACE)) {
        set_position(Vector3());
    }

    current_distance_ += (target_distance_ - current_distance_) * std::min(1.0, delta * 12.0);
    if (camera_) {
        camera_->set_position(Vector3(0.0, 0.0, current_distance_));
    }
}

void WinterCameraRig::_unhandled_input(const Ref<InputEvent> &event) {
    if (const auto *button = Object::cast_to<InputEventMouseButton>(event.ptr())) {
        if (button->is_pressed()) {
            if (button->get_button_index() == MOUSE_BUTTON_WHEEL_UP) {
                target_distance_ = std::max(16.0, target_distance_ - 3.0);
            } else if (button->get_button_index() == MOUSE_BUTTON_WHEEL_DOWN) {
                target_distance_ = std::min(80.0, target_distance_ + 3.0);
            }
        }
    }

    if (const auto *motion = Object::cast_to<InputEventMouseMotion>(event.ptr())) {
        if (Input::get_singleton()->is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)) {
            yaw_degrees_ -= motion->get_relative().x * 0.25;
        }
    }
}
