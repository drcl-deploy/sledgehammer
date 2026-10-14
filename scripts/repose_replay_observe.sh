#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: repose_replay_observe.sh [BAG_DIRECTORY]

Opens a synchronized, read-only The planner RGB-D calibration viewer. If
BAG_DIRECTORY is omitted, the newest completed bag under
$REPOSE_OBSERVE_BAG_DIR (default: $VIBE_WORKSPACE_ROOT/bags/repose_observe) is opened.
The bag's .db3 or .mcap file may also be passed directly.
EOF
}

if (($# > 1)); then
  usage >&2
  exit 2
fi
if (($# == 1)) && [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
: "${VIBE_WORKSPACE_ROOT:?Source setup_local.sh or setup.sh first}"
repository_root="${VIBE_WORKSPACE_ROOT}"
cpp_control_prefix="$(ros2 pkg prefix cpp_control)"
source "$cpp_control_prefix/share/cpp_control/scripts/ros_environment.sh"
cpp_control_source_ros "$repository_root/cyclonedds_ws"
cpp_control_check_python cv2 numpy rclpy rosbag2_py PyQt5.QtCore

export REPOSE_OBSERVE_BAG_DIR="${REPOSE_OBSERVE_BAG_DIR:-${repository_root}/bags/repose_observe}"
export QT_IM_MODULE="${VIBE_QT_IM_MODULE:-compose}"
exec /usr/bin/python3 "${script_dir}/repose_replay_observe.py" "$@"
