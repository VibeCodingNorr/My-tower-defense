#pragma once

#include <godot_cpp/classes/node3d.hpp>
#include <cstdint>

namespace godot {

// M0.5-only movement fixture: no creep AI, no combat, no navigation graph.
// The game simulation will eventually replace this fixture through commands.
class CreepDemoMover final : public Node3D {
    GDCLASS(CreepDemoMover, Node3D)

public:
    void _ready() override;
    void _physics_process(double delta) override;

    void reset_demo();
    void apply_demo_hit(int amount);
    int get_demo_phase() const;
    int get_demo_health() const;
    double get_demo_health_fraction() const;
    double get_demo_speed() const;
    double get_demo_phase_seconds() const;

protected:
    static void _bind_methods();

private:
    enum class Phase : uint8_t { Idle = 0, Moving = 1, Dying = 2 };
    Phase phase_ = Phase::Idle;
    int health_ = 100;
    int waypoint_index_ = 1;
    double phase_seconds_ = 0.0;

    void enter_dying();
    void advance_along_fixture(double delta);
};
} // namespace godot
