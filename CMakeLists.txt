cmake_minimum_required(VERSION 3.8)
project(sledgehammer)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
find_package(ament_cmake REQUIRED)
find_package(ament_index_cpp REQUIRED)
find_package(cpp_control REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(unitree_hg REQUIRED)
find_package(vision_encoders REQUIRED)
find_package(OpenCV REQUIRED)
find_package(yaml-cpp REQUIRED)

add_library(sledgehammer_core STATIC
  src/repose/cfg.cpp src/repose/sight.cpp src/repose/clips.cpp
  src/repose/approach.cpp src/repose/table.cpp src/repose/writer.cpp)
target_include_directories(sledgehammer_core PUBLIC include ${OpenCV_INCLUDE_DIRS})
target_link_libraries(sledgehammer_core
  cpp_control::cpp_control_deploy cpp_control::cpp_control_vibe_contract
  ${OpenCV_LIBS} yaml-cpp)

add_executable(repose_planner_selftest tests/repose_planner_selftest.cpp)
target_link_libraries(repose_planner_selftest sledgehammer_core)

add_executable(g1_repose_planner_node src/repose/node.cpp)
add_executable(g1_repose_planner_observe_node src/repose/observe_node.cpp)
foreach(target g1_repose_planner_node g1_repose_planner_observe_node)
  target_link_libraries(${target} sledgehammer_core)
  target_include_directories(${target} PRIVATE ${vision_encoders_INCLUDE_DIRS})
  ament_target_dependencies(${target} ament_index_cpp rclcpp std_msgs sensor_msgs
    unitree_hg vision_encoders cpp_control)
endforeach()

install(TARGETS repose_planner_selftest g1_repose_planner_node
  g1_repose_planner_observe_node DESTINATION lib/${PROJECT_NAME})
install(FILES data.lock.json DESTINATION share/${PROJECT_NAME})
install(DIRECTORY launch config DESTINATION share/${PROJECT_NAME})
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/data")
  install(DIRECTORY data DESTINATION share/${PROJECT_NAME})
endif()
file(GLOB planner_scripts scripts/*.py scripts/*.sh)
install(PROGRAMS ${planner_scripts} DESTINATION lib/${PROJECT_NAME})

if(BUILD_TESTING)
  enable_testing()
  add_test(NAME repose_planner_selftest COMMAND repose_planner_selftest
    --config ${CMAKE_CURRENT_SOURCE_DIR}/config/repose_planner/g1_sim.yaml --check-preset-parity)
  foreach(version v8 v8_5 v9 v9_1 v9_2 v9_3)
    add_test(NAME repose_planner_${version}_selftest COMMAND repose_planner_selftest
      --config ${CMAKE_CURRENT_SOURCE_DIR}/config/repose_planner/g1_sim_${version}.yaml)
  endforeach()
  add_test(NAME repose_frozen_data_selftest COMMAND repose_planner_selftest
    --config ${CMAKE_CURRENT_SOURCE_DIR}/config/repose_planner/g1_sim_v9_3.yaml
    --table ${CMAKE_CURRENT_SOURCE_DIR}/data/sys1_clips.npz
    --frames ${CMAKE_CURRENT_SOURCE_DIR}/data/sys1_bundle.npz
    --approach ${CMAKE_CURRENT_SOURCE_DIR}/data/sys1_walk/walk_forward_amateur_001__A001/motion.npz)
  add_test(NAME repose_voice_keys_selftest COMMAND /usr/bin/env python3
    ${CMAKE_CURRENT_SOURCE_DIR}/scripts/repose_voice_keys.py --self-test)
endif()

ament_package()
