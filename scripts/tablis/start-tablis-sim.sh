#!/bin/bash

source ~/.bashrc

source $(rospack find jaxon_ros_bridge)/scripts/upstart/byobu-utils.bash
SESSION_NAME=tablis
create-session

SOURCE_SCRIPT=":"
#SOURCE_SCRIPT="hiraoka-source"
# SOURCE_SCRIPT="source $HOME/ros/tablis_ws/devel/setup.bash"
PORT=11312

new-window roscore "${SOURCE_SCRIPT} && rossetlocal ${PORT} && roscore -p ${PORT}"
new-window nameserver "${SOURCE_SCRIPT} && mkdir /tmp/tablis -p && rm -f /tmp/tablis/omninames-* && omniNames -start 15006 -datadir /tmp/tablis"
sleep 1.0 # wait for roscore
new-window choreonoid "${SOURCE_SCRIPT} && rossetlocal ${PORT} && roslaunch biped_wbms_tablis choreonoid.launch"
sleep 0.5 # wait for clock
sleep 1.0 # wait for "run_id on parameter server does not match declared run_id"
new-window hrpsys "${SOURCE_SCRIPT} && rossetlocal ${PORT} && roslaunch biped_wbms_tablis hrpsys_TABLIS.launch"
sleep 1.0 # wait for robot_description
new-window rviz "${SOURCE_SCRIPT} && rossetlocal ${PORT} && rviz -d `rospack find biped_wbms_tablis`/config/tablis.rviz"
