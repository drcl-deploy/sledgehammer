"""Run only the frozen planner; the workspace starts tracker and simulator separately."""

import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    share = get_package_share_directory('sledgehammer')
    return LaunchDescription([
        DeclareLaunchArgument('env', default_value='sim', choices=['sim', 'real']),
        DeclareLaunchArgument('config', default_value=[
            share + '/config/repose_planner/g1_', LaunchConfiguration('env'), '_v9_3.yaml']),
        DeclareLaunchArgument('data_root', default_value=share),
        DeclareLaunchArgument('camera_ip', default_value=os.environ.get('VIBE_CAMERA_ADDRESS', '127.0.0.1')),
        DeclareLaunchArgument('goal_color', default_value='4'),
        Node(package='sledgehammer', executable='g1_repose_planner_node', output='screen',
             parameters=[{'config_path': LaunchConfiguration('config'),
                          'data_root': LaunchConfiguration('data_root'),
                          'camera_host': LaunchConfiguration('camera_ip'),
                          'target_color': LaunchConfiguration('goal_color')}]),
    ])
