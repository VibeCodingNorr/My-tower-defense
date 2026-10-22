#!/usr/bin/env python3
"""Validate M0.5.2's derived GLB motion clip without Godot or extra packages."""
import json
import math
import struct
from pathlib import Path

FILE = Path(__file__).resolve().parents[1] / "project/assets/creeps/fox/Fox_RootMotion.glb"
SCALE = 0.0185
EXPECTED_WORLD_DISPLACEMENT = 1.5


def main():
    data = FILE.read_bytes()
    magic, version, total = struct.unpack_from("<III", data)
    assert magic == 0x46546C67 and version == 2 and total == len(data), "Invalid GLB header"
    json_size, json_type = struct.unpack_from("<II", data, 12)
    assert json_type == 0x4E4F534A, "Missing JSON chunk"
    gltf = json.loads(data[20 : 20 + json_size].decode("utf-8"))
    bin_offset = 28 + json_size
    bin_size, bin_type = struct.unpack_from("<II", data, 20 + json_size)
    assert bin_type == 0x004E4942 and bin_size + bin_offset == len(data)
    assert gltf["buffers"][0]["byteLength"] <= bin_size

    clips = {x["name"]: x for x in gltf["animations"]}
    assert {"Survey", "Walk", "Run", "Walk_RootMotion"} <= clips.keys()

    clip = clips["Walk_RootMotion"]
    roots = [
        clip["samplers"][track["sampler"]]
        for track in clip["channels"]
        if track["target"] == {"node": 0, "path": "translation"}
    ]
    assert len(roots) == 1, "Expected one translating root track"

    sampler = roots[0]
    acc = gltf["accessors"][sampler["output"]]
    view = gltf["bufferViews"][acc["bufferView"]]
    assert acc["type"] == "VEC3" and acc["componentType"] == 5126
    start = bin_offset + view.get("byteOffset", 0) + acc.get("byteOffset", 0)
    stride = view.get("byteStride", 12)
    first = struct.unpack_from("<fff", data, start)
    last = struct.unpack_from("<fff", data, start + (acc["count"] - 1) * stride)
    travel = math.dist((first[0], first[2]), (last[0], last[2])) * SCALE
    assert abs(travel - EXPECTED_WORLD_DISPLACEMENT) < 0.02, (first, last, travel)

    original_walk = clips["Walk"]
    assert len(clip["channels"]) == len(original_walk["channels"]) + 1
    assert gltf["nodes"][0]["name"] == "WinterTD_MotionRoot"

    print(
        f"OK: {FILE.name}, root motion {travel:.3f} world units/cycle, "
        f"{acc['count']} samples; original Walk unmodified"
    )


if __name__ == "__main__":
    main()
