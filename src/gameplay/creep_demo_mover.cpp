#include "creep_demo_mover.hpp"

#include <godot_cpp/core/class_db.hpp>
#include <array>
#include <algorithm>
#include <cmath>

using namespace godot;

namespace {
// Author-time visual fixture only. Never consulted by the future maze resolver.
// These positions happen to overlap the decorative ice route in the prototype.
const std::array<Vector3, 10> kPreviewWaypoints = {{
    {-16.0f, 0.008f, -16.0f}, {16.0f, 0.008f, -16.0f},
    {16.0f, 0.008f, -8.0f}, {-16.0f, 0.008f, -8.0f},
    {-16.0f, 0.008f, 0.0f}, {16.0f, 0.008f, 0.0f},
    {16.0f, 0.008f, 8.0f}, {-16.0f, 0.008f, 8.0f},
    {-16.0f, 0.008f, 16.0f}, {16.0f, 0.008f, 16.0f}
}};
// M0.5.2 has NO independent movement speed; actual distance comes from
// sampled GLB root translation on every fixed Godot physics tick.
constexpr double kTurnRadiansPerSecond = 8.0;
constexpr double kIdleSeconds = 1.8;
constexpr double kCollapseSeconds = 2.5;
}

void CreepDemoMover::_bind_methods() {
    ClassDB::bind_method(D_METHOD("reset_demo"), &CreepDemoMover::reset_demo);
    ClassDB::bind_method(D_METHOD("apply_demo_hit", "amount"), &CreepDemoMover::apply_demo_hit);
    ClassDB::bind_method(D_METHOD("apply_demo_root_motion", "model_delta", "physics_delta"), &CreepDemoMover::apply_demo_root_motion);
    ClassDB::bind_method(D_METHOD("get_demo_phase"), &CreepDemoMover::get_demo_phase);
    ClassDB::bind_method(D_METHOD("get_demo_health"), &CreepDemoMover::get_demo_health);
    ClassDB::bind_method(D_METHOD("get_demo_health_fraction"), &CreepDemoMover::get_demo_health_fraction);
    ClassDB::bind_method(D_METHOD("get_demo_speed"), &CreepDemoMover::get_demo_speed);
    ClassDB::bind_method(D_METHOD("get_demo_phase_seconds"), &CreepDemoMover::get_demo_phase_seconds);
}

void CreepDemoMover::_ready() {
    reset_demo();
    set_physics_process(true);
}

void CreepDemoMover::reset_demo() {
    phase_ = Phase::Idle;
    phase_seconds_ = 0.0;
    waypoint_index_ = 1;
    health_ = 100;
    observed_speed_ = 0.0;
    set_position(kPreviewWaypoints.front());
    const Vector3 forward = kPreviewWaypoints[1] - kPreviewWaypoints[0];
    set_rotation(Vector3(0.0f, std::atan2(-forward.x, -forward.z), 0.0f));
    // Avoid streaking when the demo repositions the fox after a collapse.
    reset_physics_interpolation();
}

void CreepDemoMover::enter_dying() {
    health_ = 0;
    phase_ = Phase::Dying;
    phase_seconds_ = 0.0;
}

void CreepDemoMover::apply_demo_hit(int amount) {
    if (phase_ == Phase::Dying || amount <= 0) {
        return;
    }
    health_ = std::max(0, health_ - amount);
    if (health_ == 0) {
        enter_dying();
    }
}

int CreepDemoMover::get_demo_phase() const {
    return static_cast<int>(phase_);
}

int CreepDemoMover::get_demo_health() const {
    return health_;
}

double CreepDemoMover::get_demo_speed() const {
    return phase_ == Phase::Moving ? observed_speed_ : 0.0;
}

void CreepDemoMover::apply_demo_root_motion(const Vector3 &model_delta, double physics_delta) {
    if (phase_ != Phase::Moving || physics_delta <= 0.0) return;
    // The model animation is evaluated once per fixed physics step by Godot.
    // Translation is supplied in world-size units after scaling from the GLB.
    const double distance = std::sqrt(static_cast<double>(model_delta.x) * model_delta.x +
                                      static_cast<double>(model_delta.z) * model_delta.z);
    if (!std::isfinite(distance) || distance < 0.00001 || distance > 1.0) return;
    observed_speed_ = distance / physics_delta;
    advance_along_fixture(distance, physics_delta);
}

double CreepDemoMover::get_demo_health_fraction() const {
    return static_cast<double>(health_) / 100.0;
}

double CreepDemoMover::get_demo_phase_seconds() const {
    return phase_seconds_;
}

void CreepDemoMover::advance_along_fixture(double distance, double delta) {
    double remaining = distance;
    // Consumes the full physics step even when crossing multiple waypoints.
    while (remaining > 0.0 && waypoint_index_ < static_cast<int>(kPreviewWaypoints.size())) {
        const Vector3 target = kPreviewWaypoints[waypoint_index_];
        const Vector3 offset = target - get_position();
        const double distance = offset.length();
        if (distance < 0.0001) {
            ++waypoint_index_;
            continue;
        }
        const Vector3 direction = offset / distance;
        // Rotate into turns smoothly instead of instantly snapping 90 degrees.
        const double old_yaw = get_rotation().y;
        const double target_yaw = std::atan2(-direction.x, -direction.z);
        const double error = std::atan2(std::sin(target_yaw - old_yaw),
                                        std::cos(target_yaw - old_yaw));
        const double max_turn = kTurnRadiansPerSecond * delta;
        const double yaw = old_yaw + std::clamp(error, -max_turn, max_turn);
        set_rotation(Vector3(0.0f, yaw, 0.0f));
        const double move = std::min(remaining, distance);
        set_position(get_position() + direction * move);
        remaining -= move;
        if (move >= distance - 0.0001) {
            set_position(target);
            ++waypoint_index_;
        }
    }
    if (waypoint_index_ >= static_cast<int>(kPreviewWaypoints.size())) {
        enter_dying(); // End-of-demo cleanup, not a real creep death/game event.
    }
}

void CreepDemoMover::_physics_process(double delta) {
    phase_seconds_ += delta;
    switch (phase_) {
        case Phase::Idle:
            if (phase_seconds_ >= kIdleSeconds) {
                phase_ = Phase::Moving;
                phase_seconds_ = 0.0;
            }
            break;
        case Phase::Moving:
            // No independent C++ translation: consumed only from AnimationPlayer.
            break;
        case Phase::Dying:
            if (phase_seconds_ >= kCollapseSeconds) {
                reset_demo();
            }
            break;
    }
}
