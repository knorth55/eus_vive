cmake_minimum_required(VERSION 2.8.3)
project(jsk_telemanip_msgs)

find_package(catkin
  REQUIRED
  message_generation
  std_msgs
)

add_message_files(
  FILES
  TelemanipStatus.msg
  TelemanipStatusArray.msg
)

generate_messages(
  DEPENDENCIES
  std_msgs
)

catkin_package(
  CATKIN_DEPENDS
  message_runtime 
  std_msgs
)
