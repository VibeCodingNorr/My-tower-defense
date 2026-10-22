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

Expected: 96×96 snowy ground, one decorative winding ice route,
5 static CC0 Kenney tower models, 19 imported pines and 10 imported rock groups.
Camera unchanged from M0.3:
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

## M0.4.4 – Real CC0 3D models (visual-only)
Screenshot feedback made it clear that primitive towers and cone-like trees
could not achieve the target visual quality. The scene now includes **12 bundled
GLB models** selected from Kenney's 3D Tower Defense Kit and Nature Kit:
- 5 **noninteractive** towers made from Kenney tower models/parts
- 19 varied pines (snow-covered models and evergreen variants)
- 10 rock clusters, 3 ice crystals and 2 winter wooden structures
- The previous hand-built primitive towers, cone trees and rock blocks were
  removed. Small terrain ground shrubs/chips remain as background details.

The assets are bundled with the repo (Godot imports their GLB scenes) and
require no additional download step. Licensing/provenance: `docs/ASSET_LICENSES.md`.
We deliberately import only a handful of CC0 models rather than the whole pack.
The winding blue route remains a **visual demo**, not a fixed creep route.
No gameplay or camera code was added or changed.

## M0.4.3 – Art-direction pass (visual-only)
After the second screenshot, the ice/snow colors, repetitive terrain, snowdrift
discs and cone-like tower markers still looked artificial compared with WC3.

Updated test scene:
- Snow with more varied cold/warm rock patches and subtle grit
- Same 9-piece visual path, now painted continuously with less obvious stripes
- 5 small fantasy watchtower silhouettes (stone bodies, timber trim, colored
  pitched roofs, tiny crests), **static scenery only**
- 19 three-layer spruce trees with better silhouettes
- 10 multi-rock clusters, 20 low shrubs and 10 stone chips
- 7 conspicuous flat snowdrift discs removed
- Camera position, controls, zoom and C++ source remain untouched

The look is still an original procedural placeholder, not a Warcraft asset
replacement. Proper hand-painted assets can be considered after the style is
approved. There are no creeps, damage, maze placement or gameplay mechanics.

## M0.4.2 – Winter scene polish (visual-only)
The M0.4.1 screenshot showed that the ground and overlay planes were
overexposed and looked like flat strips. The ice path is now drawn directly
into the **same ground shader** as the snow: continuous rounded connections,
frosted banks, no geometric seam, muted colors and subtle 1m grid.
The route shown is a visual comparison example, **not a gameplay route**.

Static size references: **5** stone plinths with small beacons;
**10** faceted rocks with snow caps, **19** low-poly spruces, **7** snowdrifts.
The settled M0.3 C++ camera is not touched. There are no creeps, dynamic
pathfinding, build commands or gameplay systems.

For CachyOS, after closing Godot and switching to this branch:
```sh
git pull --ff-only
cmake --build --preset debug --parallel 4
godot --path project --editor
```
Press F5 and compare winter mood, route outlines and tower scale.
The Linux CI additionally performs a headless Godot scene import/runtime
smoke test on Godot 4.7.2, after building the native extension.

## Verification
The GitHub workflow builds on Linux and Windows. A successful native build and
Godot runtime test are still required before marking M0.2 verified. Generated
binaries are deliberately not committed.
