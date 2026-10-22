# WinterTD 3D — M0.4 (stacked on M0.3)

Godot 4.7.2 + C++20 via GDExtension. This milestone contains a native RTS camera,
procedural snow and ice-lane shaders, static environment props, and build infrastructure.
There are **no gameplay systems** yet.

## Requirements
- Godot 4.7.2 stable
- CMake 3.24+, Ninja, Git, a C++20 compiler (GCC/Clang or MSVC)
- Internet on first CMake configure to fetch godot-cpp 10.0.0-stable

## Build
Run these from the repository root:

```sh
cmake --preset debug
cmake --build --preset debug --parallel 2
```

Then open the `project/` directory with Godot 4.7.2 and press F5.
For Windows, use the VS 2022 **x64 Native Tools Command Prompt**.
For CachyOS, install cmake, ninja, git, gcc, python, and Godot.

## Controls
- WASD / arrow keys: pan camera over map
- Q / E or middle mouse drag: rotate
- Mouse wheel: smooth zoom
- Space: return camera target to map center

Expected: 96×96 snowy ground, a 9-segment winding icy test route, 5 static
round tower pads and 6 low-poly rocks. Camera unchanged from M0.3:
57° downward, yaw 0°, FOV 46°, distance 42 units; zoom spans 16–80 units.

`src/camera/` holds the only active native class. Other subsystems will be
added in later milestones. The renderer and camera are not part of gameplay
simulation. No Warcraft III proprietary assets or code are included.

## WC3 camera framing
Screenshot iteration: the original 62° pitch flattened the test markers;
57° exposes more vertical faces. Placeholder cubes were too bright, so their
albedo and the ambient/sun intensity are lowered. The map stays 96×96.

The M0.3 perspective is a first tuning pass based on the provided Wintermaul TD
reference screenshot. M0.2's working C++ extension and interactions remain
unchanged. No gameplay systems or final graphics are included.

## M0.4 scene-only test
The nine ice meshes are visual markers, **not** navigation geometry or a fixed
creep route. Building pads and rocks are also noninteractive placeholders.
The M0.3 camera source code and binaries are unchanged; a rebuild is optional
if you already built the GDExtension. Check ice/snow contrast and prop scale
in a Godot F5 run before approving the look.

## Verification
The GitHub workflow builds on Linux and Windows. A successful native build and
Godot runtime test are still required before marking M0.2 verified. Generated
binaries are deliberately not committed.
