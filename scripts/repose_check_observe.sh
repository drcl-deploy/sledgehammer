#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: repose_check_observe.sh [record]

Offboard bridge client + the live observe check. Sibling of
repose_stream_observe.sh, minus the labelling: it answers "is localization
stable here". Add `record` to capture every live RGB-D/observation tuple for
offline production replay; no button presses or colour stages are required.

The onboard side is g1_repose_planner_localization.launch.py, which holds the
controller in its nominal SONIC stand under calibration_lock — no reference
motion, no planner reference, so the robot stands and only the v8 observe block
runs.

    ros2 launch sledgehammer g1_repose_planner_localization.launch.py \
        artifact_dir:=<export> env:=real       # onboard
    bash repose_check_observe.sh record         # offboard

Environment:
  VIBE_BRIDGE_ADDRESS      onboard bridge host
  BRIDGE_ROS_DOMAIN_ID     isolated offboard domain (default 71)
  REPOSE_LOCALIZATION_BAG_DIR  bag root (default: repo/bags/repose_localization)
EOF
}

record=false
while (($#)); do
  case "$1" in
    record) record=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "check_observe: unknown argument '$1'" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

script_path="$(readlink -f -- "${BASH_SOURCE[0]}")"
script_dir="$(cd -- "$(dirname -- "${script_path}")" && pwd)"
: "${VIBE_WORKSPACE_ROOT:?Source setup_local.sh or setup.sh first}"
repository_root="${VIBE_WORKSPACE_ROOT}"
cpp_control_prefix="$(ros2 pkg prefix cpp_control)"
source "$cpp_control_prefix/share/cpp_control/scripts/ros_environment.sh"
cpp_control_source_ros "$repository_root/cyclonedds_ws"
cpp_control_check_python cv2 numpy rclpy cpp_control.msg
if [[ "$record" == true ]]; then cpp_control_check_python rosbag2_py; fi

export ROS_DOMAIN_ID="${BRIDGE_ROS_DOMAIN_ID:-71}"
unset CYCLONEDDS_URI
export ROS_LOCALHOST_ONLY=1
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"
export VIBE_BRIDGE_ADDRESS="${VIBE_BRIDGE_ADDRESS:-gilfoyle-rth}"

bridge_config="$(ros2 pkg prefix cdr_tcp_bridge)/share/cdr_tcp_bridge/config/repose_calibration.yaml"

children=()
cleanup() {
  trap - EXIT INT TERM HUP
  for pid in "${children[@]}"; do kill -INT "${pid}" 2>/dev/null || true; done
  for pid in "${children[@]}"; do wait "${pid}" 2>/dev/null || true; done
}
trap cleanup EXIT
trap 'exit 130' INT TERM HUP

echo "check_observe: server=${VIBE_BRIDGE_ADDRESS}:5556 domain=${ROS_DOMAIN_ID}"
ros2 run cdr_tcp_bridge bridge_client.sh -p config_path:="${bridge_config}" &
children+=("$!")

/usr/bin/python3 "${script_dir}/repose_check_observe.py" &
children+=("$!")

if [[ "${record}" == true ]]; then
  ros2 run sledgehammer repose_record_localization.sh &
  children+=("$!")
fi

wait -n "${children[@]}"
