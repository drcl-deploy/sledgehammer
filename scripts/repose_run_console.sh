#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: repose_run_console.sh [--color N]

Opens the planner console: the planner's state pane, and the one place the target
colour is set. Unlike the viewers, this joins the EXPERIMENT domain — the goal
colour travels upstream to the robot and the telemetry bridge is one-way — so
source setup.sh (real) or setup_local.sh (simulation) before running it, the
same file the task launch was started with.

Live viewing and recording stay where they were: scripts/vibe/stream_vibes.sh
carries the planner already.
EOF
}

if (($#)) && [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${VIBE_WORKSPACE_ROOT:-}" ]]; then
  set +u
  source "${VIBE_WORKSPACE_ROOT}/cyclonedds_ws/install/setup.bash"
  set -u
elif [[ -z "${AMENT_PREFIX_PATH:-}" ]]; then
  echo 'Source setup_local.sh or setup.sh before starting the console.' >&2
  exit 1
fi

# No domain override here on purpose: the console must sit where the controller
# is, which is whatever the sourced experiment setup selected.
echo "run_console: console on ROS domain ${ROS_DOMAIN_ID:-0}"
exec python3 "${script_dir}/repose_console.py" "$@"
