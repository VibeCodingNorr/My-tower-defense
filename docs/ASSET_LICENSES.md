# External 3D asset license and provenance

Selected GLB models used in WinterTD's M0.4 visual test scene.

**Author:** Kenney
**License:** Creative Commons CC0 1.0 Universal (public domain dedication).
Attribution is not required, but we include it for transparency.

- Official source for Tower Defense Kit: https://kenney.nl/assets/tower-defense-kit
- Official source for Nature Kit: https://kenney.nl/assets/nature-kit
- Redistributable public GLB mirror used for curated import: https://github.com/Hidencod/tge-assets
- CC0 license: https://creativecommons.org/publicdomain/zero/1.0/

Included Tower Defense Kit GLB files:
- `project/assets/kenney/tower-defense-kit/snow-detail-tree-large.glb`
- `project/assets/kenney/tower-defense-kit/snow-detail-tree.glb`
- `project/assets/kenney/tower-defense-kit/snow-detail-rocks.glb`
- `project/assets/kenney/tower-defense-kit/snow-detail-crystal.glb`
- `project/assets/kenney/tower-defense-kit/snow-wood-structure.glb`
- `project/assets/kenney/tower-defense-kit/tower-square-bottom-a.glb`
- `project/assets/kenney/tower-defense-kit/tower-square-middle-a.glb`
- `project/assets/kenney/tower-defense-kit/tower-square-roof-a.glb`
- `project/assets/kenney/tower-defense-kit/tower-round-build-a.glb`
- `project/assets/kenney/tower-defense-kit/tower-square-build-a.glb`

Included Nature Kit GLB files:
- `project/assets/kenney/nature-kit/tree-pinedefaulta.glb`
- `project/assets/kenney/nature-kit/tree-pineroundb.glb`

Only these selected GLBs are bundled, and their upstream Git blob SHA-1 values are preserved.
These are static, non-animated environment references. Future animated creatures
require a separate licensed rigged 3D character pipeline.
Warcraft III graphics, models and textures are **not** included.

## Animated Creep Test Asset – Frostfuchs (M0.5)

- **File:** `project/assets/creeps/fox/Fox.glb`
- **Source:** https://github.com/KhronosGroup/glTF-Sample-Assets/tree/main/Models/Fox
- **Model:** PixelMannen (2014), **CC0 1.0 Universal**.
- **Rigging and animations:** tomkranis (2014), **CC BY 4.0**.
- **glTF conversion:** @AsoboStudio and @scurest (2017), **CC BY 4.0**.
- **Original animation clips:** `Survey`, `Walk`, `Run`.
- **Note:** No actual death animation is included; the temporary collapse is coded in `creep_preview_view.gd`.
- **Changes:** Embedded as Godot scene at 0.0185× scale, visually named Frostfuchs, with separate C++ path-preview movement and health bar; source binary GLB unchanged.
- **License:** https://creativecommons.org/licenses/by/4.0/

This notice provides the CC-BY attribution for the animation and conversion.
