# sledgehammer

The frozen Repose V9.3 cube-reorientation planner for [ViBe](https://github.com/lok-i/vibe).
An optional demo alongside tracker deployment in [vibe_ws](https://github.com/drcl-deploy/vibe_ws).

## status

Initial repository scaffold. The planner still runs from `cpp_control`;
extraction into this repository is pending.

For the current two-terminal simulator demo and gamepad controls, see
[vibe_ws usage](https://github.com/drcl-deploy/vibe_ws#usage).

## scope

This repository will contain the planner, its configurations, and the frozen
data needed to reproduce the V9.3 demo:

- `sys1_clips.npz` and `sys1_library.npz`
- required motion frames and the approach walking motion

Tracker inference and robot control stay in
[cpp_control](https://github.com/drcl-deploy/cpp_control).
Exported policy and encoder models belong in `vibe_ws/artifacts/`.

The planner and data have not been copied here yet. Extraction and regression
gates are tracked in the [workspace migration plan](https://github.com/drcl-deploy/vibe_ws/blob/main/docs/migration.md#remaining-phases).
