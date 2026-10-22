# WinterTD 3D — M0.2

Godot 4.7.2 + C++20 via GDExtension. This milestone contains a native RTS camera,
a placeholder grid/terrain, environment lighting, and build infrastructure.
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

Expected: 48×48 placeholder ground grid, three cubes, simple sky and
directional light, camera pitched at 52 degrees.

`src/camera/` holds the only active native class. Other subsystems will be
added in later milestones. The renderer and camera are not part of gameplay
simulation. No Warcraft III proprietary assets or code are included.

## Verification
The GitHub workflow builds on Linux and Windows. A successful native build and
Godot runtime test are still required before marking M0.2 verified. Generated
binaries are deliberately not committed.
