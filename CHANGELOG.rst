^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package eus_vive
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

0.0.3 (2020-09-18)
------------------
* Merge pull request `#14 <https://github.com/knorth55/eus_vive/issues/14>`_ from knorth55/update-calib
  Update calib
* update perspective
* skip calib service in main
* add both arm calib service
* update rviz config
* update rviz config
* tune volume
* update rviz config
* update eus_vive sounder
* update rviz config
* add rviz config
* update eus_vive_status_sounder
* modify package version in package.xml
* add CHANGELOG.rst
* add gripper state visualiztion
* publish gripper open rate
* add start and stop sound
* add gripper sound
* add front and top visualization
* update kinetic.rosinstall
* update kinetic.rosinstall
* tune sound volume
* fix target pos z for non-head control
* updte baxter head->shoulder-x-distance
* Merge pull request `#13 <https://github.com/knorth55/eus_vive/issues/13>`_ from knorth55/add-hand-close
  Add hand close in status msg
* launch xdisplay false
* fix color
* fix typo
* launch xdisplay true
* add output
* add hand_close status visualizer
* update comment in launch files
* move status visualizer
* publish hand_close status
* add hand_close in EusViveStatus.msg
* use package:// in reset_button.perspective
* Contributors: Shingo Kitagawa

0.0.2 (2020-08-28)
------------------
* update rvizconfig
* update rviz config
* add baxter_miraikan_remote_display.launch
* fix baxter_miraikan_remote_vive.launch
* add baxter_vr_display.launch
* fix twitter topic name
* udpate rviz config
* update rviz config
* add reset_button perspective
* add baxter rviz
* update logging launch
* add launch_xdisplay
* use xacro instead of xacro.py
* set softhand as default
* fix typo in baxter-vr-main.l
* update rviz config
* update sample launch
* update baxter.launch and baxter_vr.launch
* move baxter_logging
* udate reset-teleop-pose
* add controller-timeout
* update rvizconfig
* fix respeaker.launch
* add republish
* Merge pull request `#12 <https://github.com/knorth55/eus_vive/issues/12>`_ from knorth55/remote-baxter
* fix baxter_miraikan_remote_vive.launch
* update rviz config
* fix baxter_vr.launch
* update rviz config
* split to audio_play and respeaker
* add baxter_miraikan_remote_vive.launch
* rename rviz config
* update rviz config
* add launch_baxter arg and split into baxter.launch
* mv: baxter_miraikan_vive.launch -> baxter_miraikan_mirror_vive.launch
* change arg: miraikan -> custom_xdisplay
* pass respeaker arg
* update audio_common
* update readme
* update .travis to 0.5.12
* Merge pull request `#11 <https://github.com/knorth55/eus_vive/issues/11>`_ from knorth55/fix-torso
* speak when ready
* reset torso controller
* update parameters
* fix typo
* use torso when both arm is moving
* use normal ik for pr2
* add torso-ik-weight parameter
* fix arm-cb
* add filter-use-torso and add torso-z-thresh
* fix arm-cb
* refactor arm-cb
* fix euslint
* use current coords when one arm is moving
* use opposite-arm-coords for one arm ik
* update readme
* Merge pull request `#10 <https://github.com/knorth55/eus_vive/issues/10>`_ from knorth55/use-oculus
* update current-end-coords when start
* update get-target-coords for oculus
* return when current-end-coords is nil
* add head-shoulder distance
* update robot-oculus-interface
* fix launch
* when oculus do not use base now
* enable head movement in oculus
* return nil
* split head-cb
* fix typo in robot-vive-interface.l
* fix typo
* add sample launches
* add oculus arg
* rename vive to vr
* add device-type in pr2/baxter-vr-main.l
* add oculus robot interfaces
* refactor robot interfaces
* add gripper-button args in main-loop
* refactor interfaces
* use tfl
* use base -> vrbase
* add robot-vr-interface.l
* use controller
* Update README.md
* add buffer_queue_size
* update udev
* Fix readme
* fix db_client.launch
* fix baxter visualize robot model
* update README
* add kodak udev
* add kodak visualization
* add kodak launch
* update kinetic.rosinstall
* update baxte reset-teleop-pose
* make pr2 faster
* update baxter rviz config
* install softhand in left gripper of baxter 73b2
* Contributors: Shingo Kitagawa

0.0.1 (2020-01-23)
------------------
* fix typo in launch
* Merge pull request `#8 <https://github.com/knorth55/eus_vive/issues/8>`_ from knorth55/pr1012
  20120114-20200121 experiments
* rename baxter rosbag node
* add logging
* fix typo in pr1040_vive.launch
* add prosilica commentout
* add audio_play for pr2
* update kinetic.rosinstall
* update kinetic.rosinstall
* update rvizconfig
* updat rviz config
* update rviz config
* update rviz config
* add queue_size for point_cloud_xyzrgb
* add pr1012 and pr1040 launch
* Merge pull request `#9 <https://github.com/knorth55/eus_vive/issues/9>`_ from knorth55/add-travis
  add travis
* update readme
* add travis
* add respeaker in launch
* update .rosinstall
* update package.xml
* Merge pull request `#7 <https://github.com/knorth55/eus_vive/issues/7>`_ from knorth55/baxter-hmd
  add baxter head camera and hmd view
* update camera pose
* update baxter vive visualization rviz config
* update baxter scale parameter
* update get-head-end-coords for baxter
* update pr2 :get-head-end-coords
* update get-hmd->vive-coords for baxter
* update virtual_camera_info_publisher to fit camera size
* update get-head-end-coords for speedup
* refactor :move-head
* update head->shoulder-x-distance
* update baxter parameters
* update get-head-end-coords
* refactor baxter-vive-interface.l
* rotate headcoords to set world coords
* override move-head and get-head-end-coords
* override head-cb in baxter-vive-interface
* add baxter head camera and hmd view
* upadte device name
* Merge pull request `#6 <https://github.com/knorth55/eus_vive/issues/6>`_ from knorth55/20191106-demo
  add softhand demo
* add softhand mode
* lint
* add workspace for 73b2
* add posture to not move torso often
* update kinfu parameter
* update rviz config
* set volume_size for kinfu
* use vive like camera info
* add main and vive args in sample launch
* add kinfu rviz visualization
* use kinfu
* update pr2_vive_visualization.rviz
* add screen for service_button
* add rviz_camera_stream
* use rviz display as vive display
* use ik-optomotiongen
* solve inverse-kinematics not from current pose
* set pr2 gripper gain
* set loop-enable nil for pr2
* Merge pull request `#5 <https://github.com/knorth55/eus_vive/issues/5>`_ from knorth55/use-rosparam
  Use rosparam for workspace and vive id
* fix typo in robot-vive-interface
* add rqt_service_buttons
* fix typo
* set workspace for miraikan demo
* add workspace
* add samples
* refactor vive id rosparam
* add baxter_73b2.launch
* use rosparam to pass vive id
* add baxter_rosbag_play.launch
* Contributors: Shingo Kitagawa

0.0.0 (2019-08-23)
------------------
* update visualization rviz config
* Update README.md
* add realsense tf publisher
* update reset-teleop-pose
* update baxter_miraikan
* add baxter_miraikan.launch
* add calib service
* set default loop-enable nil
* fix typo
* set default loop-enable nil
* add enable and disable button
* add reset button
* use empty service
* add rqt_service_caller
* add reset service
* add robotsound_jp
* update baxter min-z thresh
* change initial pose
* info in signal-hook
* add rosbag record
* add debug and twitter args
* add workspace
* move launch/baxter and launch/pr2
* rotate 45 :y vive controller
* visualize ik result in track error
* update visualization rviz config
* update baxter visualization rviz config
* add baxter_visualization launch
* switch b and c vive lighthouse
  lighthouse_LHB_8E924CC3 is working better than lighthouse_LHB_11CFA4E1
* reset when speaked
* fix typo
* split into baxter_logging launch
* add miraikan arg
* refactor db_client.launch
* update logger to add eus_vive_status
* update rvizconfig
* add vive arg for launch
* change speak contents
* update eus_vive_status_sounder
* speak when enable/disable arm
* refactor
* add alert sounder
* speak in calibration
* fix action
* add other action
* add twitter for baxter demo
* add mongodb logging
* change camera view
* update pr2 camera position
* update baxter_vive.rviz
* fix typo
* add baxter urdf for custom gripper
* add mask_rcnn launch
* display eus_vive_status_visualizer in xdisplay
* move robot-state-visualize-topic-name in robot-vive-interface.l
* publish EusViveStatusArray
* add EusViveStatusVisualizer
* add EusViveStatusArray msg
* update baxter irtviewer camera
* update kinetic.rosinstall
* update diff thresh
* visualize irtviewer in xdisplay
* calib only in no head mode
* do not move arm when target-coords is too far away
* euslint
* update current coords
* update kinetic.rosinstall
* fix inverse-kinematics-raw args
* use frame-id without slash
* use inverse-kinematics-raw
* update rviz config
* reset when stopped
* update rviz config
* use anonymous nil
* update rviz config
* update rvizconfig
* add overlay text
* refine ros out
* wait 0.5 second for next button input
* update rvizconfig
* update package.xml
* publish DisplayRobotState
* refactor
* update irtviewer before calibration
* add baxter rviz config
* use error
* add target coords visualization
* update nvidia-driver in readme
* Update README.md
* slow down baxter arm
* use menu button for enable
* add collision status cb
* add grasp timeout
* update readme
* use trackpad to enable arm for baxter
* fix typo
* update readme
* update robot when enabled
* update kinetic.rosinstall
* add baxter_interface
* use baxter av-scale 2.0
* start from untuck-pose
* Merge pull request `#4 <https://github.com/knorth55/eus_vive/issues/4>`_ from knorth55/mirror
  add mirror mode
* add calibration error
* try again when calibration is failed
* check if calibration is correct
* remove unused line
* set s0 joint limit
* fix typo
* cancel all controller in signal hook
* use mirror coordinate
* fix typo
* cancel angle-vector in signal-hook
* add mirror in launch
* add mirror in base-cb
* add mirror mode
* use bezier_with_velocity
* use av-tm 100
* update baxter e0 joint limit
* overwrite e0 joint limit for calm motion
* set av-tm 0.1 for baxter
* switch to ps3joy in int and kill
* run :switch-joy-to-ps3joy when closing
* set larger scale for baxter
* Update kinetic.rosinstall
* add torso mode
* add ik-stop-step
* do not use torso for pr2
* use inverse-kinematics-raw for baxter
* fix typo
* fix gripper-status-topic-name
* fix visualize
* update pr2 paramter
* update pr2 parameters
* use *irtviewer*
* Merge pull request `#3 <https://github.com/knorth55/eus_vive/issues/3>`_ from knorth55/support-baxter
  Support baxter vive control
* set interpolation and mode
* add min-time
* fix typo in calib-vive
* update readme
* do not wait gripper
* refactor baxter launch
* add baxter vive programs
* fix robot-vive-interface
* updat hyper param
* update node name
* fix typo
* update hyper param
* remove scale
* move hyper parameter
* fix typo
* add robot-vive-interface and robot-move-base-vive-interface
* rename function
* add kinetic.rosinstall
* add no head mode
* calib scale in rarm
* add scale calib
* refactor pr2-vive-interface.l
* use reset-pose for initial pose
* add grasping-p to stop when robot is grasping
* refactor pr2-vive-interface.l
* Update README.md
* refactor pr2-vive-interface
* update readme
* update readme
* add grip button function
* remap move base: use trigger for safe move base
* Merge pull request `#2 <https://github.com/knorth55/eus_vive/issues/2>`_ from knorth55/no-head-interface
  refactor and refine move base method
* fix typo
* use trackpad button
* fix typo
* fix typo
* fix typo
* fix typo
* use set-val
* euslint
* fix move base
* renam function
* refactor pr2-vive-interface
* use process
* use main-loop
* remove commentout
* add main-loop method
* add base option
* refactor pr2-vive-interface.l
* fix typo
* Merge pull request `#1 <https://github.com/knorth55/eus_vive/issues/1>`_ from knorth55/pr2-vive-interface
  add pr2-vive-interface.l
* update scale paramter
* fix typo
* add pr2-vive-interface.l
* fix move base
* add move base
* format pr2-vive.l
* fix format
* update av-scale
* fix feedback
* add vivration feedback
* update readme
* eye distance: 0.1 -> 0.063
* Update README.md
* make virtual camera stereo
* make include dir
* cancel angle-vector when stopped
* fix head rpy
* scale z axis
* start from reset-manip-pose
* add kinfu
* make robot motion faster
* republish compressed image
* add grasp and stop button
* update scale
* fix typo
* add head-cb
* add pr2_vive.launch
* add euslisp script
* add catkin package
* Initial commit
* Contributors: Shingo Kitagawa
