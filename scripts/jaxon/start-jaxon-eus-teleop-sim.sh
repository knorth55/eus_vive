#!/bin/bash

source ~/.bashrc

source $(rospack find jaxon_ros_bridge)/scripts/upstart/byobu-utils.bash
SESSION_NAME=wbms_follower
create-session

SOURCE_SCRIPT=":"
# SOURCE_SCRIPT="hiraoka-source"
# SOURCE_SCRIPT="source ~/ros/tablis_ws/devel/setup.bash"
TABLIS_MASTER="rossetlocal 11312"
#TABLIS_MASTER="rossettablis"
JAXON_MASTER="rossetlocal"
#JAXON_MASTER="rossetjaxon_red"

new-window connect_leader "${SOURCE_SCRIPT} && ${TABLIS_MASTER} && roslaunch eus_teleop tablis_bridge_leader.launch filtered:=true"
new-window connect_follower "${SOURCE_SCRIPT} && ${JAXON_MASTER} && roslaunch eus_teleop tablis_bridge_follower.launch"
new-window wbms "${SOURCE_SCRIPT} && ${JAXON_MASTER} && roslaunch biped_wbms_jaxon wbms.launch"
new-window eus_teleop "${SOURCE_SCRIPT} && ${JAXON_MASTER} && roslaunch eus_teleop jaxon_tablis_choreonoid.launch"
