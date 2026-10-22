# WinterTD 3D — M0.5 (stacked on M0.4)

Godot 4.7.2 + C++20 via GDExtension. This milestone contains a native RTS camera,
procedural snow and ice-lane shaders, static environment props, and build infrastructure.
This milestone adds an **isolated C++ movement test fixture**; no combat, tower
building, multiplayer or gameplay pathfinder exists yet.

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

## M0.4.6 – Low-contrast tower masonry and pathside tree line
The M0.4.5 screenshot showed that the towers were now mostly white and that
almost all trees sat offscreen at the far edge. This limited art-only pass:
- Caps tower material brightness and recolors purple accents to muted brown-gray
  stone, preserving the texture atlas details.
- Adds 20 staggered pine/snow-tree instances and 8 snow rock groups beside the
  decorative route and at the top/bottom edges.
- Leaves the 5 static test towers, maze-shaped ice visual, C++ camera,
  zoom and input controls completely unchanged.

No dynamic maze navigation, tower building, creep movement or combat yet.
The imported models stay under Kenney's CC0 license, documented in
`docs/ASSET_LICENSES.md`. This version needs a local Godot screenshot check.

## M0.4.5 – WC3-style palette + tree silhouette pass
After the third visual screenshot, Kenney's original magenta stone looked
out of place next to the ice and snow. A **visual-only GDScript** on the main
scene now applies `winter_tower_palette.gdshader` only to imported
BuildPad tower meshes. The shader preserves original Kenney UV/color-map
details and remaps pronounced purple pixels into weathered grey stone.
The 19 static roadside trees are now a mixed forest of **15** larger evergreen
pines and **4** snow-covered conifers rather than mostly white cones.
A dark translucent background keeps the camera test instructions readable.

This is scene styling, not C++ gameplay; the C++ camera is untouched,
and **no future Maze-building path is encoded by the decorative ice markings**.
A working local Godot F5 check of the new material is required before approval.

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
require no additional download step. Only selected Kenney models are bundled. Licensing/provenance: `docs/ASSET_LICENSES.md`.
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

## M0.5 – Animated Frost Fox prototype

- Native C++ `CreepDemoMover` updates a single test creature in `_physics_process`
  (fixed engine timestep, no system clock randomness).
- Movement passes through **author-time demo waypoints** drawn over the decorative
  ice. These are *not* the future maze/pathfinding implementation.
- A bundled rigged `Fox.glb` plays the real `Survey` (idle) and `Walk` joint
  animation cycles; a scripted visual collapse is the temporary death stand-in.
- A camera-facing health bar displays 100 HP. Press **H** to deduct 25 test HP,
  **R** to restart. Reaching 0 HP or the end of the preview route triggers a
  short fall, then automatic reset. Camera controls remain from M0.3.
- Presentation and UI are in `project/scripts/creep_preview_view.gd`, while
  waypoint progression and HP fixture state live in C++.
- Licensing: the fox model is CC0; rigging/animations and conversion are
  **CC BY 4.0**, with all credits in `docs/ASSET_LICENSES.md`.

### M0.5 Test

Close Godot, then in your existing clone:

```bash
git fetch origin && git switch --track origin/feat/m0-5-animated-creep && cmake --preset debug && cmake --build --preset debug --parallel 4 && godot --path project --editor
```

Press F5. Expect idle for ~1.8s, real limb animation while walking along the
ice, camera-facing HP bar, H and R interactions, and a temporary fall/reset.
Please report whether the fox faces the direction of travel and share errors.

### Automated smoke test

CI checks both native build variants and (Linux) Godot GLB import. It then runs
`godot --headless --path project --script res://tests/test_creep_preview.gd`
to validate the rigged model clips and C++ demo HP/death/reset operations.

### M0.5.1 – Gait/ground-contact correction

Screenshot showed a sliding or floating fox. The GLB Walk clip lasts 0.708s,
while the original demo moved 4.3 world units/second. Preview speed is now
**2.1 units/second**, roughly 1.49 units per walk cycle, so paws visually keep
up. Root height is at terrain height (not 0.18 units above), and a softly
faded ground-contact shadow helps show contact. Heading turns are smoothed
in the C++ physics step. Godot physics transform interpolation is enabled to
reduce visible render-step jitter; reset teleport calls
`reset_physics_interpolation()` to avoid trails. No camera, game economy,
creep nav or actual combat changes.
