^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package eus_teleop
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

0.0.10 (2023-04-02)
-------------------
* update readme
* flake8
* disable bash and mypy lint
* flake8
* disable shellcheck
* update readme
* move jaxon tablis scripts in eus_vive
* update tablis launch
* Contributors: Shingo Kitagawa

0.0.9 (2023-01-19)
------------------
* add pr2 and baxter video
* Merge pull request `#47 <https://github.com/knorth55/eus_teleop/issues/47>`_ from knorth55/spacenav-base
* euslint
* updat ereadme
* toggle spacenav base
* fix typo
* add base-cb methods
* euslint
* update controller-button-common-p
* change torso mode
* fix typo
* add controller-button-common-p
* add check torso/base mode functions
* add joy index val
* publish when loop enable
* publish stop base topic
* fix typo
* update jaxon-vr-main.l
* pr2 torso for spacenav
* support spacenav move base
* fix typo in pr2-vr-main.l
* set pr2 spacenav button
* refactor robot-move-base-vr-interface
* refactor main-loop args
* add base button options
* abstract base-cb
* Merge pull request `#46 <https://github.com/knorth55/eus_teleop/issues/46>`_ from knorth55/jaxon
  Add JAXON + SpaceNav, Tablis Demo
* disable md034
* euslint
* add movies
* update readme
* fix typo in readme
* use current-end-coords for spacenav
* refactor jaxon-tablis-interface.l
* fix typo in jaxon-vr-main
* fix typo
* move :reset in :ros-init
* update jaxon tablis params
* add tablis jaxon launch
* add mirror arg in jaxon_spacenav_choreonoid
* change default args in jaxon launch
* load jaxon-tablis-interface in jaxon-vr-main
* add jaxon-tablis-interface
* add feedback pose topic val
* add ros-init
* use prog1 for init and return self in init
* publish leg pose stamp in euslisp
* refactor robot-vr-interface
* add publish-command-pose
* fix typo in robot-vr-interface
* update slot val name
* fix typo
* add always-publish-command-pose
* fix spacenav drifting
* update robot model
* relay leg slave
* refactor robot-vr-interface
* move functions
* update current-end-coords from pose in jaxon
* disable update-current-end-coords in jaxon
* fix topic name
* fix robot-vr-interface visualize
* fix typo
* add advertise
* fix slot search
* support trackpad too
* support other button for base-cb
* check if slot is boundp or not
* fix typo
* rename launches
* add jaxon sample launches
* add jaxon launch files
* add jaxon-vr-main
* publish to command pose topic
* add jaxon custom set reference end coords
* use set-reference-end-coords in robot-vr-interface
* add set-reference-tablis-coords
* refactor parameters
* add arm-cb-solve-ik val
* move update-robot-model to correct position
* add get-target-coords place holder
* add jaxon spacenav interface
* require robot-move-base-spacenav-interface in pr2-spacenav-interface
* fix visualize coords
* add robot-move-base-spacenav-interface.l
* add robot-move-base-oculus-interface.l
* add jaxon-vr-interface
* Merge pull request `#30 <https://github.com/knorth55/eus_teleop/issues/30>`_ from knorth55/dragon-spacenav-demo
* add dragon example in readme
* add dragon.rosinstall
* fix get-target-coords
* add scale
* refactor dragon vr interface
* add dragon vr and gazebo launch
* refactor spacenav euslisp codes
* add dragon-vr-main.l for dragon spacenav demo
* fix typo
* update readme
* update readme
* markdownlint
* update baxter vive sample
* update tablis sample launches
* update readme
* update readme
* Merge pull request `#44 <https://github.com/knorth55/eus_teleop/issues/44>`_ from knorth55/tablis-demo
* fix mirror control
* add mirror arguments
* add tablis.rosinstall
* add tablis bridge follower launch in baxter_vr
* add tablis launches
* add baxter_tablis_remote.launch
* fix tablis get-target-coords
* add scale
* update baxter scale
* use vals for topic names
* call send-super at the end
* refactor parameters
* show rqt gui unless display
* check if device id is set in param
* draw objects in all step
* dont send joy when no diff
* add make-*-irtviewer and camera-model func
* refactor
* euslint
* refactor
* add return t
* fix tablis interface
* comment out pr2 gazebo
* add sound_play
* fix sample
* add move base interface
* refactor launch
* merge pr1012 and pr1040 launch
* use require
* change org method names
* overwrite start-grasp and stop-grasp
* add tablis in main
* add baxter and pr2 launches
* add baxter tablis interface
* add pr2 tablis interface
* add robot-tablis-interface
* add update-robot-model method
* update baxter_tabletop_object_detector.launch
* fix baxter_logging.launch
* fix baxter.launch
* add allow-other-keys t for baxter-init
* fix baxter-init &rest args
* Contributors: Shingo Kitagawa

0.0.8 (2022-08-15)
------------------
* Merge pull request `#43 <https://github.com/knorth55/eus_teleop/issues/43>`_ from Kanazawanaoaki/add-moveit-to-depend
* Merge pull request `#42 <https://github.com/knorth55/eus_teleop/issues/42>`_ from Kanazawanaoaki/add-eus_teleop-to-rosinstall
* Add pr2_moveit_config to depend in package.xml
* Add eus_teleop to rosinstall
* Merge pull request `#41 <https://github.com/knorth55/eus_teleop/issues/41>`_ from knorth55/baxter-moveit-args
  add gripper args in baxter_moveit.launch
* add gripper args in baxter_moveit.launch
* Merge pull request `#40 <https://github.com/knorth55/eus_teleop/issues/40>`_ from knorth55/use-baxter-softhand-interface
  use baxter-softhand-interface in jsk_robot
* use baxter-softhand-interface in jsk_robot
* Merge pull request `#37 <https://github.com/knorth55/eus_teleop/issues/37>`_ from YUKINA-3252/global-time
* Make global_time_enabled true
* Update README.md
* update rviz config
* update moveit rviz
* update rviz
* update rviz config
* add allow-other-keys
* update *baxter* with potentio vector
* add finger1,2,3 rotate method in baxter-interface
* Merge pull request `#36 <https://github.com/knorth55/eus_teleop/issues/36>`_ from softyanija/update-rotate-angle
* add rotate-angle in baxter-interface.l
* update baxter.rosinstall
* Merge pull request `#35 <https://github.com/knorth55/eus_teleop/issues/35>`_ from YUKINA-3252/baxter_torso_l515
* update baxter torso l515 pose
* add readme
* add baxter_spacenav_gazebo.launch
* update baxter_vr_gazebo.launch
* Merge pull request `#34 <https://github.com/knorth55/eus_teleop/issues/34>`_ from knorth55/spacenav
  add baxter spacenav launch
* euslint
* update thumb button
* fix typo
* remove unused enable
* add baxter spacenav launch
* updata l515 pose
* set default baxter spacenav arm: rarm
* fix spacenav button p
* set slot variables
* Contributors: Kanazawa, Naoaki Kanazawa, Shingo Kitagawa, YUKINA-3252, softyanija

0.0.7 (2022-02-08)
------------------
* add new config
* refactor for grasp mask rcnn
* update rvizconfig
* update workspace marker
* update rviz config
* enable rviz
* update rviz config
* refactor baxter_tabletop_object_detector.launch
* update workspace config
* update rviz config
* update tabletop detector launch
* Merge pull request `#33 <https://github.com/knorth55/eus_teleop/issues/33>`_ from tohirose/cylinder-experiment
  change l515_torso_pose.yaml
* change l515_torso_pose.yaml
* add grasp mask rcnn launch
* update baxter.rosinstall
* Merge pull request `#19 <https://github.com/knorth55/eus_teleop/issues/19>`_ from knorth55/no-window
* add no-window version
* use outlier removal with cluster indices
* update rosbag rviz
* update baxter_rosbag_play.launch
* update rosbag_record.launch
* add baxter_rosbag_record.launch
* updte rviz config
* update l515
* update rviz config
* use resized pointcloud
* tube parameters
* update tabletop detector
* update rviz config
* update workspace
* launch tabletop
* update rviz config
* update camera pose
* fix manager name
* update yaml path
* update l515 pose
* add tabletop_object_detector for baxter
* disable camera logging to mongodb
* support :arms in baxter-interface
* udpate rosinstall
* Merge pull request `#32 <https://github.com/knorth55/eus_teleop/issues/32>`_ from knorth55/knorth55-patch-1
* disable textlint
* Update linter.yaml
* Update README.md
* Update README.md
* use pazeshun dynamixel_motor branch
* Contributors: Shingo Kitagawa

0.0.6 (2021-08-07)
------------------
* use :set-torque-limit-step for softhand v1 and v2
* Merge pull request `#31 <https://github.com/knorth55/eus_teleop/issues/31>`_ from knorth55/set-torque-limit
  add set-torque-limit methods in baxter-interface.l
* fix typo
* add set-torque-limit methods in baxter-interface.l
* fix typo
* add thumb-rotate
* remove commentout
* fix typo
* support spacenav for baxter
* fix typo
* Contributors: Shingo Kitagawa

0.0.5 (2021-07-06)
------------------
* update rviz config
* update rviz config
* updat erviz
* use tabbed buttons for gui
* update rviz config
* Revert "set compress default true"
  This reverts commit 0f35d946439183911c41425d0df2aa641184862c.
* set compress default true
* add rqt_gui arg
* add hmd in rosbag
* change arg name
* record rviz images
* update baxter_vr_display logging
* fix typo in baxter_vr_display.launch
* fix rosbag file prefix
* add more args in baxter_display_remote launch
* add logging in baxter_vr_display.launch
* refactor republish and add camera info relay
* add more topics
* update readme
* update rosbag name in pr2_logging.launch
* update baxter_logging rosbag name
* update fc.rosinstall
* update baxter rosbag topic
* update baxter logging rosbag
* add pr2 compress flag
* update baxter logging launch
* update rviz config
* add main name in baxter_vr_display.launch
* update rvizconfig
* fix typo
* fix typo in head
* update rviz config
* update ipd
* add spherical stereo head rviz
* add republish arg in baxter_vive.launch
* fix spherical camera tf
* update baxter_moveit.rviz
* set logging true
* update baxter_moveit_remote.launch
* refactor sample launches
* update readme
* update rosinstall
* add control arg in baxter_vr.launch
* add baxter_miraikan_remote_robot.launch
* fix typo in readme
* update pr2 reset pose
* fix missing arg
* update readme
* update fc.rosinstall
* Merge pull request `#22 <https://github.com/knorth55/eus_teleop/issues/22>`_ from knorth55/add-spacenav
* implement spacenav interface
* show error when button method not found
* add spacenav interfaces
* Contributors: Shingo Kitagawa

0.0.4 (2021-03-21)
------------------
* update reset perspective
* update rviz config
* update rviz config
* add image and depth type
* update rvizconfig
* use x264
* update rviz config
* use padding rviz_textured_sphere
* rviz config update
* fix robot-height in get-target-coords-from-pos-rot
* euslint
* add get-target-coords-from-pos-rot
* add VPNC Command
* update readme
* update baxter.rosinstall
* update rviz config
* update rviz config
* update baxter_vr.launch
* update main workflows
* update baxter.rosinstall
* add influxdb
* update rviz config
* update baxter shoulder distance
* update rviz config
* update rviz config
* update l515 pose
* update fc.rosinstall
* github markdown lint
* update README.md
* fix typo in comment
* update baxter vr display rviz
* update env.sh
* add limit-in-front arg in baxter-init
* change to default gripper type
* add baxter_73b2_moveit.launch
* add baxter_moveit.rviz
* add moveit arg
* add arm_control_mode
* add arm_interpolation arg
* update pr2 vr visualization
* update virtual camera tf
* add IMAGE_DEPTH_TYPE
* update readme
* change button name
* fix typo
* update readme
* add baxter.rosinstall.kinetic/melodic
* update readme
* update readme
* change the button name
* add head arg
* add pr2_shmpwk_vive.launch
* add head argument in pr2_73b2_vive.launch
* fix typo
* update signal hook
* refactor baxter logging launch
* fix typo
* update fc.rosinstall
* fix typo
* fix baxter logging
* add compressedDepth republish
* change the resolution for usb3.0
* add realsense baxter launch
* disable jscpd linter
* update fc.rosinstall
* suppot spherical stereo for baxter logging
* add realsense torso
* add comment to skip sc1090
* add spherical stereo
* add +x in scripts/env.sh
* add env.sh
* update readme
* update fc.rosinstall
* fix typo in baxter_vr_display
* fix typo
* move rqt_gui.launch
* refactor baxter_vr_gazebo.launch
* fix signal-hook for pr2
* fix controller-button-p for other controller
* typo: enable -> loop-enable in robot-vr-interface
* add comment in robot-vive-interface.l
* do not use pass_all_args in pr2_vr.launch
* stop using pass_all_args in baxter launch
* update elp_usb.launch
* add libuvc_camera as exec_depend
* Update 99-insta.rules
* fix typo in pr2_vr_display.launch
* fix typo
* add audio_ns
* add display
* fix typo in pr2 launch
* add toggle and hold grasp button
* add loop-enable for each arms
* rename to loop-enable-arm
* check args in set-arm-val and get-arm-val
* update perspective
* not wait for grasping
* add gripper button gui in baxter and pr2
* add gripper button gui
* update robot speech
* add start/stop grasp service
* add reset enable disable service for each arm
* rename to elp_usb.launch
* add insta360_air.launch
* update elp_usb_4k.launch
* refactor robot-vive-interface
* add elp 4k camera launch
* set debug arg false
* add pr2-vr-interface
* require robot-vr-interface
* add baxter-vr-interface
* use require
* fix typo
* use reset-arm-val
* fix typo
* move signal-hook in robot-vr-interface.l
* refactor arm val slots
* add clear-costmap
* update reset-arm
* add baxter_remote_hmd_visualization.rviz
* add baxter_vr_remote_display_visualization.rviz
* add pr2_logging and pr2_vr_display
* fix service button
* add remote sound play node
* move rqt_gui in baxter_vr_display.launch
* euslint
* add euslint
* flake8
* markdown lint
* add linter
* Merge pull request `#18 <https://github.com/knorth55/eus_teleop/issues/18>`_ from knorth55/softhand-v2-devel
* update reset-teleop-pose
* fix baxter-interface
* add reset-pose
* add softhand-v2 methods
* fix arm-motion-cb
* fix  typo in baxter-interface.l
* Merge pull request `#20 <https://github.com/knorth55/eus_teleop/issues/20>`_ from knorth55/use-4k
* Merge branch 'use-4k' into softhand-v2-devel
* use kodak pixpro as 4k
* fix robot-vr-interface.l
* add create-viewer
* fix typo in baxter-oculus-interface.l
* fix typo in baxter-interface.l
* euslint
* do not use dolist
* use if instead of when, unless
* fix arguments order
* chmod -x
* override e1 min angle limit
* move limit in baxter-interface
* add baxter-util.l
* fix typo in baxter-vr-main
* euslint
* move controller-button-p in robot-vr-interface.l
* rename methods
* set default param
* use args
* add l/rgripper args in baxter-oculus
* add thumb-rotate-cb for baxter+softhand-v2
* add l/rgripper args
* refactor robot-vr-interface.l
* fix grasp variable set
* add start-heater and stop-heater
* add get-gripper-type and get-gripper-interface
* fix typo in baxter-interface.l
* update README
* fix typo in .ci.rosinstall
* update fc.rosinstall and .ci.rosinstall
* Merge pull request `#16 <https://github.com/knorth55/eus_teleop/issues/16>`_ from knorth55/softhand-v2-devel
  support softhand v2
* change launch arg: gripper_softhand -> gripper_type
* add softhand-v2 in baxter-interface
* Merge pull request `#15 <https://github.com/knorth55/eus_teleop/issues/15>`_ from knorth55/update-gripper-control
  add button toggle control
* rename button-toggle-p -> gripper-button-toggle-p
* fix button-toggle
* add button_toggle rosparam in oculus
* fix button-toggle-p
* Merge remote-tracking branch 'origin/master' into update-gripper-control
* Update README.md
* fix readme
* update readme
* add button_toggle launch args
* remove unused launch args
* add button-toggle-p in robot-vive-interface.l
* Merge pull request `#17 <https://github.com/knorth55/eus_teleop/issues/17>`_ from knorth55/use-github-actions
* update readme
* update github actions config
* skip vive_ros
* add .ci.rosinstall
* update fc.rosinstall
* update README.md
* add UPSTREAM_WORKSPACE
* rename to fc.rosinstall
* add github actions
* fix package.xml
* remove travis
* Contributors: Shingo Kitagawa, Shmpei Wakabayashi, Shumpei Wakabayashi

0.0.3 (2020-09-18)
------------------
* Merge pull request `#14 <https://github.com/knorth55/eus_teleop/issues/14>`_ from knorth55/update-calib
  Update calib
* update perspective
* skip calib service in main
* add both arm calib service
* update rviz config
* update rviz config
* tune volume
* update rviz config
* update eus_teleop sounder
* update rviz config
* add rviz config
* update eus_teleop_status_sounder
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
* Merge pull request `#13 <https://github.com/knorth55/eus_teleop/issues/13>`_ from knorth55/add-hand-close
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
* add hand_close in EusTeleopStatus.msg
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
* Merge pull request `#12 <https://github.com/knorth55/eus_teleop/issues/12>`_ from knorth55/remote-baxter
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
* Merge pull request `#11 <https://github.com/knorth55/eus_teleop/issues/11>`_ from knorth55/fix-torso
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
* Merge pull request `#10 <https://github.com/knorth55/eus_teleop/issues/10>`_ from knorth55/use-oculus
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
* Merge pull request `#8 <https://github.com/knorth55/eus_teleop/issues/8>`_ from knorth55/pr1012
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
* Merge pull request `#9 <https://github.com/knorth55/eus_teleop/issues/9>`_ from knorth55/add-travis
  add travis
* update readme
* add travis
* add respeaker in launch
* update .rosinstall
* update package.xml
* Merge pull request `#7 <https://github.com/knorth55/eus_teleop/issues/7>`_ from knorth55/baxter-hmd
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
* Merge pull request `#6 <https://github.com/knorth55/eus_teleop/issues/6>`_ from knorth55/20191106-demo
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
* Merge pull request `#5 <https://github.com/knorth55/eus_teleop/issues/5>`_ from knorth55/use-rosparam
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
* update logger to add eus_teleop_status
* update rvizconfig
* add vive arg for launch
* change speak contents
* update eus_teleop_status_sounder
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
* display eus_teleop_status_visualizer in xdisplay
* move robot-state-visualize-topic-name in robot-vive-interface.l
* publish EusTeleopStatusArray
* add EusTeleopStatusVisualizer
* add EusTeleopStatusArray msg
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
* Merge pull request `#4 <https://github.com/knorth55/eus_teleop/issues/4>`_ from knorth55/mirror
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
* Merge pull request `#3 <https://github.com/knorth55/eus_teleop/issues/3>`_ from knorth55/support-baxter
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
* Merge pull request `#2 <https://github.com/knorth55/eus_teleop/issues/2>`_ from knorth55/no-head-interface
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
* Merge pull request `#1 <https://github.com/knorth55/eus_teleop/issues/1>`_ from knorth55/pr2-vive-interface
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
