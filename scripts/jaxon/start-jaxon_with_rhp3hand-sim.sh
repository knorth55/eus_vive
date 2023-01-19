#!/bin/bash

source $(rospack find jaxon_ros_bridge)/scripts/upstart/byobu-utils.bash
SESSION_NAME=jaxon
create-session

SOURCE_SCRIPT=":"
# SOURCE_SCRIPT="hiraoka-source"
# SOURCE_SCRIPT="source ~/ros/tablis_ws/devel/setup.bash"

new-window roscore "rossetlocal && rossetip && roscore"
new-window nameserver "rm -f /tmp/omninames-* && omniNames -start 15005 -datadir /tmp"
sleep 0.5 # wait for roscore
new-window choreonoid "rossetlocal && rossetip && ${SOURCE_SCRIPT} && roslaunch auto_stabilizer_config choreonoid_JAXON_WITH_RHP3HAND.launch"
sleep 1.0 # wait for clock and spawning models
new-window hrpsys "rossetlocal && rossetip && ${SOURCE_SCRIPT} && roslaunch auto_stabilizer_config hrpsys_JAXON_WITH_RHP3HAND.launch"
sleep 1.0 # wait for robot_description
