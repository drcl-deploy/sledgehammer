"""Run the frozen planner and its console in this terminal (including SSH/tmux)."""

import os
import sys

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, LogInfo, OpaqueFunction, Shutdown
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def start_planner(context):
    console = LaunchConfiguration('console').perform(context) == 'true'
    terminal = None
    if console and sys.stdin.isatty():
        terminal = os.ttyname(sys.stdin.fileno())
    actions = []
    if console and terminal is None:
        actions.append(LogInfo(msg='No interactive terminal: starting planner without console. '
                                   'Use an SSH TTY/tmux for color keys, or console:=false.'))
    actions.append(Node(
        package='sledgehammer', executable='g1_repose_planner_node',
        output={'both': 'log'} if terminal else 'screen',
        parameters=[{'config_path': LaunchConfiguration('config'),
                     'data_root': LaunchConfiguration('data_root'),
                     'camera_host': LaunchConfiguration('camera_ip'),
                     'target_color': LaunchConfiguration('goal_color')}],
        on_exit=Shutdown(reason='planner exited')))
    if terminal:
        # ROS launch pipes child stdin. Give the existing console the actual
        # controlling terminal so keys and drawing work without a GUI terminal.
        actions.append(Node(
            package='sledgehammer', executable='repose_console.py', output={'both': 'log'},
            arguments=['--tty', terminal, '--color', LaunchConfiguration('goal_color')],
            on_exit=Shutdown(reason='planner console exited')))
    return actions


def generate_launch_description():
    share = get_package_share_directory('sledgehammer')
    return LaunchDescription([
        DeclareLaunchArgument('env', default_value='sim', choices=['sim', 'real']),
        DeclareLaunchArgument('config', default_value=[
            share + '/config/repose_planner/g1_', LaunchConfiguration('env'), '_v9_3.yaml']),
        DeclareLaunchArgument('data_root', default_value=share),
        DeclareLaunchArgument('camera_ip', default_value=os.environ.get('VIBE_CAMERA_ADDRESS', '127.0.0.1')),
        DeclareLaunchArgument('goal_color', default_value='4'),
        DeclareLaunchArgument('console', default_value='true', choices=['true', 'false'],
                              description='Interactive color/status console in this terminal'),
        OpaqueFunction(function=start_planner),
    ])
