"""Resolve current and pre-migration Repose bag types without changing the bag."""

from rosidl_runtime_py.utilities import get_message


def bag_message(type_name):
    # Only package ownership changed; these three CDR layouts are identical.
    legacy = {
        'cpp_control/msg/PlannerStatus': 'sledgehammer/msg/PlannerStatus',
        'cpp_control/msg/CubeObservation': 'sledgehammer/msg/CubeObservation',
        'cpp_control/msg/CalibrationState': 'sledgehammer/msg/CalibrationState',
    }
    return get_message(legacy.get(type_name, type_name))
