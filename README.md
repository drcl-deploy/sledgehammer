# sledgehammer

The frozen Repose V9.3 cube-reorientation planner for [ViBe](https://github.com/lok-i/vibe).
An optional demo alongside tracker deployment in [vibe_ws](https://github.com/drcl-deploy/vibe_ws).

## usage

Build through [vibe_ws](https://github.com/drcl-deploy/vibe_ws#install), then run
from its workspace root in three terminals:

```bash
./run.sh sim repose-v9.3
./run.sh tracker repose-v9.3 --with-planner
./run.sh planner repose-v9.3
```

Use your imported experiment name in place of `repose-v9.3` for another export.
**RB** enters nominal stand and disarms; **A** arms the planner from stand.
`--goal-color 0..5` selects red, orange, green, yellow, blue or pink; set the same
value in both tracker and planner terminals.

To launch just this package after sourcing the workspace:

```bash
ros2 launch sledgehammer planner.launch.py env:=sim goal_color:=4
ros2 run sledgehammer repose_console.py
```

The workspace's supervised tracker wrapper stops its launch if this planner
disappears. The planner idles when controller status or low-state becomes stale.

## data

| file | purpose |
|---|---|
| `data/sys1_clips.npz` | clip table |
| `data/sys1_library.npz` | frozen source library |
| `data/sys1_bundle.npz` | selected motion frames, including contact commands |
| `data/sys1_walk/.../motion.npz` | approach and disarmed walking |

All four files ship in this repository and install with the ROS package.
[data.lock.json](data.lock.json) records hashes and provenance. V9.3 reads the
baked frames without a training checkout. See [data notes](data/README.md) for
the verified array equality and the sidecars required when rebaking.

Policy and encoder ONNX belong in the workspace's ignored `artifacts/`.
Tracker inference, robot control and the existing ROS message types remain in
[cpp_control](https://github.com/drcl-deploy/cpp_control). Topics stay
`/tracker/reference`, `/vibe/controller/status`, `/vibe/planner/status`, `/lowstate`
and `/vibe/sonic/goal_color`.

## test

```bash
colcon test --packages-select sledgehammer
colcon test-result --verbose
```

Nine package tests cover historical presets, V9.3 planning with shipped data,
and voice-key parsing. The workspace adds isolated disconnect checks and the
operator regression. Joystick and hardware acceptance remain pending.
