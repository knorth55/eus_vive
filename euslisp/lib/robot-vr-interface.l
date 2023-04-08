;; -*- mode: lisp;-*-

(ros::load-ros-manifest "actionlib_msgs")
(ros::load-ros-manifest "eus_vive")
(ros::load-ros-manifest "moveit_msgs")
(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "std_msgs")
(ros::load-ros-manifest "std_srvs")

(require :display-robot-state "package://jsk_interactive_marker/euslisp/display-robot-state.l")


(defclass robot-vr-interface
  :super propertied-object
  :slots (robot
          robot-interface
          tfl
          camera-model
          base-frame-id
          head-frame-id
          collision-status-topic-type
          robot-state-visualize-topic-name
          irtviewer-visualize-topic-name
          eus-vive-status-topic-name
          eus-vive-reset-service-name
          eus-vive-reset-larm-service-name
          eus-vive-reset-rarm-service-name
          eus-vive-enable-service-name
          eus-vive-enable-larm-service-name
          eus-vive-enable-rarm-service-name
          eus-vive-disable-service-name
          eus-vive-disable-larm-service-name
          eus-vive-disable-rarm-service-name
          eus-vive-calib-service-name
          eus-vive-calib-larm-service-name
          eus-vive-calib-rarm-service-name
          eus-vive-start-grasp-larm-service-name
          eus-vive-start-grasp-rarm-service-name
          eus-vive-stop-grasp-larm-service-name
          eus-vive-stop-grasp-rarm-service-name
          eus-vive-toggle-grasp-service-name
          eus-vive-hold-grasp-service-name
          loop-enable
          draw-object-list
          gripper-button-toggle-p
          larm-enable
          larm-grasp
          larm-grasping-p
          larm-grasp-timeout-p
          larm-grasp-start-time
          larm-collision-p
          larm-current-end-coords
          larm-track-error-p
          larm-coords-visualize-topic-name
          larm-grasp-visualize-topic-name
          larm-gripper-status-topic-name
          larm-collision-status-topic-name
          larm-gripper-type
          larm-loop-enable
          larm-ref-end-coords
          larm-command-pose-topic-name
          larm-feedback-pose-topic-name
          lleg-current-end-coords
          lleg-command-pose-topic-name
          lleg-feedback-pose-topic-name
          rarm-enable
          rarm-grasp
          rarm-grasping-p
          rarm-grasp-timeout-p
          rarm-grasp-start-time
          rarm-collision-p
          rarm-current-end-coords
          rarm-track-error-p
          rarm-coords-visualize-topic-name
          rarm-grasp-visualize-topic-name
          rarm-gripper-status-topic-name
          rarm-collision-status-topic-name
          rarm-gripper-type
          rarm-loop-enable
          rarm-ref-end-coords
          rarm-command-pose-topic-name
          rarm-feedback-pose-topic-name
          rleg-current-end-coords
          rleg-command-pose-topic-name
          rleg-feedback-pose-topic-name
          always-command-current-coords
          ik-stop-step
          scale
          av-tm
          av-scale
          min-time
          torso-av-tm
          torso-av-scale
          torso-min-time
          torso-z-thresh
          torso-ik-weight
          grasp-timeout-time
          rate
          arm-length
          end-coords-pos-diff-thresh
          target-coords-max-x
          target-coords-max-y
          target-coords-max-z
          target-coords-min-x
          target-coords-min-y
          target-coords-min-z
          head->shoulder-x-distance
          head->shoulder-z-distance
          arm-cb-solve-ik
          ;; base
          base-enable
          joy-org-topic-name
          joy-other-topic-name
          vx
          vy
          vw
          vx-thresh
          vy-thresh
          vw-thresh
          vx-scale
          vy-scale
          vw-scale
          prev-base-move
          joy-deadman-button-index
          joy-torso-up-button-index
          joy-torso-down-button-index
          joy-unsafe-teleop-button-index
          joy-vx-axes-index
          joy-vy-axes-index
          joy-vw-axes-index
          ))


(defmethod robot-vr-interface
  (:init (&key (loop-enable t) (lgripper nil) (rgripper nil))
    (send self :set-val 'larm-gripper-type lgripper)
    (send self :set-val 'rarm-gripper-type rgripper)
    ;; for workspace
    (send self :set-val 'target-coords-max-x (ros::get-param "/eus_vive/workspace/max_x" nil))
    (send self :set-val 'target-coords-max-y (ros::get-param "/eus_vive/workspace/max_y" nil))
    (send self :set-val 'target-coords-max-z (ros::get-param "/eus_vive/workspace/max_z" nil))
    (send self :set-val 'target-coords-min-x (ros::get-param "/eus_vive/workspace/min_x" nil))
    (send self :set-val 'target-coords-min-y (ros::get-param "/eus_vive/workspace/min_y" nil))
    (send self :set-val 'target-coords-min-z (ros::get-param "/eus_vive/workspace/min_z" nil))
    ;; for eus_vive
    (send self :set-val 'robot-state-visualize-topic-name "/display_robot_state")
    (send self :set-val 'irtviewer-visualize-topic-name "/eus_vive/irtviewer/image")
    (send self :set-val 'eus-vive-status-topic-name "/eus_vive/status")
    (send self :set-val 'eus-vive-reset-service-name "/eus_vive/reset")
    (send self :set-val 'eus-vive-reset-larm-service-name "/eus_vive/larm/reset")
    (send self :set-val 'eus-vive-reset-rarm-service-name "/eus_vive/rarm/reset")
    (send self :set-val 'eus-vive-enable-service-name "/eus_vive/enable")
    (send self :set-val 'eus-vive-enable-larm-service-name "/eus_vive/larm/enable")
    (send self :set-val 'eus-vive-enable-rarm-service-name "/eus_vive/rarm/enable")
    (send self :set-val 'eus-vive-disable-service-name "/eus_vive/disable")
    (send self :set-val 'eus-vive-disable-larm-service-name "/eus_vive/larm/disable")
    (send self :set-val 'eus-vive-disable-rarm-service-name "/eus_vive/rarm/disable")
    (send self :set-val 'eus-vive-calib-service-name "/eus_vive/calibrate")
    (send self :set-val 'eus-vive-calib-larm-service-name "/eus_vive/larm/calibrate")
    (send self :set-val 'eus-vive-calib-rarm-service-name "/eus_vive/rarm/calibrate")
    (send self :set-val 'eus-vive-start-grasp-larm-service-name "/eus_vive/larm/start_grasp")
    (send self :set-val 'eus-vive-start-grasp-rarm-service-name "/eus_vive/rarm/start_grasp")
    (send self :set-val 'eus-vive-stop-grasp-larm-service-name "/eus_vive/larm/stop_grasp")
    (send self :set-val 'eus-vive-stop-grasp-rarm-service-name "/eus_vive/rarm/stop_grasp")
    (send self :set-val 'eus-vive-toggle-grasp-service-name "/eus_vive/toggle_grasp")
    (send self :set-val 'eus-vive-hold-grasp-service-name "/eus_vive/hold_grasp")
    (send self :set-val 'gripper-button-toggle-p (ros::get-param "/eus_vive/button_toggle" t))

    (send self :set-arm-val :larm :coords-visualize-topic-name "/eus_vive/left/target_pose_stamped")
    (send self :set-arm-val :rarm :coords-visualize-topic-name "/eus_vive/right/target_pose_stamped")
    (send self :set-arm-val :larm :grasp-visualize-topic-name "/eus_vive/left/hand_open_rate")
    (send self :set-arm-val :rarm :grasp-visualize-topic-name "/eus_vive/right/hand_open_rate")
    (send self :set-val 'tfl (instance ros::transform-listener :init))

    self)
  (:ros-init ()
    (send self :reset :loop-enable loop-enable)
    (ros::subscribe larm-gripper-status-topic-name
                    actionlib_msgs::GoalStatusArray #'send self :gripper-status-cb :larm)
    (ros::subscribe rarm-gripper-status-topic-name
                    actionlib_msgs::GoalStatusArray #'send self :gripper-status-cb :rarm)
    (if (and larm-collision-status-topic-name
             rarm-collision-status-topic-name
             collision-status-topic-type)
      (progn
        (ros::subscribe larm-collision-status-topic-name
                        collision-status-topic-type #'send self :collision-status-cb :larm)
        (ros::subscribe rarm-collision-status-topic-name
                        collision-status-topic-type #'send self :collision-status-cb :rarm)))
    (ros::advertise larm-coords-visualize-topic-name geometry_msgs::PoseStamped 1)
    (ros::advertise rarm-coords-visualize-topic-name geometry_msgs::PoseStamped 1)
    (ros::advertise larm-grasp-visualize-topic-name std_msgs::Float32 1)
    (ros::advertise rarm-grasp-visualize-topic-name std_msgs::Float32 1)
    (ros::advertise robot-state-visualize-topic-name moveit_msgs::DisplayRobotState 1)
    (ros::advertise eus-vive-status-topic-name eus_vive::EusViveStatusArray 1)
    (ros::advertise-service eus-vive-reset-service-name std_srvs::Empty
                            #'send self :reset-service)
    (ros::advertise-service eus-vive-reset-larm-service-name std_srvs::Empty
                            #'send self :reset-larm-service)
    (ros::advertise-service eus-vive-reset-rarm-service-name std_srvs::Empty
                            #'send self :reset-rarm-service)
    (ros::advertise-service eus-vive-enable-service-name std_srvs::Empty
                            #'send self :enable-service)
    (ros::advertise-service eus-vive-enable-larm-service-name std_srvs::Empty
                            #'send self :enable-larm-service)
    (ros::advertise-service eus-vive-enable-rarm-service-name std_srvs::Empty
                            #'send self :enable-rarm-service)
    (ros::advertise-service eus-vive-disable-service-name std_srvs::Empty
                            #'send self :disable-service)
    (ros::advertise-service eus-vive-disable-larm-service-name std_srvs::Empty
                            #'send self :disable-larm-service)
    (ros::advertise-service eus-vive-disable-rarm-service-name std_srvs::Empty
                            #'send self :disable-rarm-service)
    (ros::advertise-service eus-vive-calib-service-name std_srvs::Empty
                            #'send self :calib-service)
    (ros::advertise-service eus-vive-calib-larm-service-name std_srvs::Empty
                            #'send self :calib-larm-service)
    (ros::advertise-service eus-vive-calib-rarm-service-name std_srvs::Empty
                            #'send self :calib-rarm-service)
    (ros::advertise-service eus-vive-start-grasp-larm-service-name std_srvs::Empty
                            #'send self :start-grasp-larm-service)
    (ros::advertise-service eus-vive-start-grasp-rarm-service-name std_srvs::Empty
                            #'send self :start-grasp-rarm-service)
    (ros::advertise-service eus-vive-stop-grasp-larm-service-name std_srvs::Empty
                            #'send self :stop-grasp-larm-service)
    (ros::advertise-service eus-vive-stop-grasp-rarm-service-name std_srvs::Empty
                            #'send self :stop-grasp-rarm-service)
    (ros::advertise-service eus-vive-toggle-grasp-service-name std_srvs::Empty
                            #'send self :toggle-grasp-service)
    (ros::advertise-service eus-vive-hold-grasp-service-name std_srvs::Empty
                            #'send self :hold-grasp-service)
    (ros::advertise irtviewer-visualize-topic-name sensor_msgs::Image 1)
    t)
  ;; fundamental methods
  (:reset-arm-val (arm)
    (send self :set-arm-val arm :enable nil)
    (send self :set-arm-val arm :grasp nil)
    (send self :set-arm-val arm :grasping-p nil)
    (send self :set-arm-val arm :grasp-timeout-p nil)
    (send self :set-arm-val arm :grasp-start-time nil)
    (send self :set-arm-val arm :collision-p nil)
    (send self :set-arm-val arm :current-end-coords nil)
    (send self :set-arm-val arm :track-error-p nil))
  (:reset (&key (loop-enable t) (torso t))
    (send self :set-val 'loop-enable loop-enable)
    (send self :set-arm-val :larm :loop-enable loop-enable)
    (send self :set-arm-val :rarm :loop-enable loop-enable)
    (send self :reset-arm :larm :wait nil)
    (send self :reset-arm :rarm :wait nil)
    (if torso (send self :reset-torso :wait nil))
    (send robot-interface :wait-interpolation))
  (:reset-arm (arm &key (wait t) (reset-pose :reset-pose))
    (send robot-interface :cancel-angle-vector
          :controller-type (send self :get-arm-controller arm))
    (send self :reset-arm-val arm)
    (send self :stop-grasp arm :wait nil)
    (send self :angle-vector (send robot reset-pose) 5000
          (send self :get-arm-controller arm))
    (if wait
      (send robot-interface :wait-interpolation
            (send self :get-arm-controller arm))))
  (:reset-torso (&key (wait t) (reset-pose :reset-pose))
    (if (find-method robot-interface :torso-controller)
      (progn
        (send robot-interface :cancel-angle-vector :controller-type :torso-controller)
        (send self :angle-vector (send robot reset-pose) 5000 :torso-controller)
        (if wait (send robot-interface :wait-interpolation :torso-controller)))))
  (:enable (&key (torso t))
    (send self :set-val 'loop-enable t)
    (send self :set-arm-val :larm :loop-enable t)
    (send self :set-arm-val :rarm :loop-enable t)
    (send robot-interface :cancel-angle-vector
          :controller-type (send self :get-arm-controller :larm))
    (send robot-interface :cancel-angle-vector
          :controller-type (send self :get-arm-controller :rarm))
    ;; (send self :enable-arm :larm)
    ;; (send self :enable-arm :rarm)
    (if (and torso (find-method robot-interface :torso-controller))
      (send robot-interface :cancel-angle-vector :controller-type :torso-controller))
    )
  (:enable-arm (arm)
    (send robot-interface :cancel-angle-vector
          :controller-type (send self :get-arm-controller arm))
    (send self :set-arm-val arm :enable t)
    )
  (:enable-torso ()
    (if (find-method robot-interface :torso-controller)
      (send robot-interface :cancel-angle-vector :controller-type :torso-controller)))
  (:disable (&key (torso t))
    (send self :set-val 'loop-enable nil)
    (send self :set-arm-val :larm :loop-enable nil)
    (send self :set-arm-val :rarm :loop-enable nil)
    (send robot-interface :cancel-angle-vector
          :controller-type (send self :get-arm-controller :larm))
    (send robot-interface :cancel-angle-vector
          :controller-type (send self :get-arm-controller :rarm))
    ; (send self :disable-arm :larm)
    ; (send self :disable-arm :rarm)
    (if (and torso (find-method robot-interface :torso-controller))
      (send robot-interface :cancel-angle-vector :controller-type :torso-controller))
    )
  (:disable-arm (arm)
    (send robot-interface :cancel-angle-vector
          :controller-type (send self :get-arm-controller arm))
    (send self :set-arm-val arm :enable nil))
  (:disable-torso ()
    (if (find-method robot-interface :torso-controller)
      (send robot-interface :cancel-angle-vector :controller-type :torso-controller)))
  (:calibrate (&optional (arm :rarm))
    (let (calib-p)
      (setq calib-p (send *ti* :calib-controller arm))
      (if (not calib-p)
        (send *ri* :speak "Please try calibration again." :wait t :volume 0.6))
      calib-p))
  ;; services
  (:reset-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Reset button pressed. I go back to reset pose." :wait nil :volume 0.6)
      (send self :reset :loop-enable nil)
      res))
  (:reset-larm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Reset button pressed. Left arm goes back to reset pose." :wait nil :volume 0.6)
      (send self :reset-arm :larm :wait t)
      res))
  (:reset-rarm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Reset button pressed. Right arm goes back to reset pose." :wait nil :volume 0.6)
      (send self :reset-arm :rarm :wait t)
      res))
  (:enable-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Enable button pressed. Demo starts." :wait nil :volume 0.6)
      (send self :enable)
      res))
  (:enable-larm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Enable button pressed. Left arm starts." :wait nil :volume 0.6)
      (send self :set-val 'loop-enable t)
      (send self :set-arm-val :larm :loop-enable t)
      (send self :enable-arm :larm)
      res))
  (:enable-rarm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Enable button pressed. Right arm starts." :wait nil :volume 0.6)
      (send self :set-val 'loop-enable t)
      (send self :set-arm-val :rarm :loop-enable t)
      (send self :enable-arm :rarm)
      res))
  (:disable-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Disable button pressed. Demo stops." :wait nil :volume 0.6)
      (send self :disable)
      res))
  (:disable-larm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Disable button pressed. Left arm stops." :wait nil :volume 0.6)
      (send self :set-arm-val :larm :loop-enable nil)
      (if (not rarm-loop-enable) (send self :set-val 'loop-enable nil))
      (send self :disable-arm :larm)
      (send self :disable-torso)
      res))
  (:disable-rarm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Disable button pressed. Right arm stops." :wait nil :volume 0.6)
      (send self :set-arm-val :rarm :loop-enable nil)
      (if (not larm-loop-enable) (send self :set-val 'loop-enable nil))
      (send self :disable-arm :rarm)
      (send self :disable-torso)
      res))
  (:calib-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Calibrate button pressed." :wait t :volume 0.6)
      (send self :set-val 'loop-enable t)
      (send self :set-arm-val :larm :loop-enable t)
      (send self :set-arm-val :rarm :loop-enable t)
      (send self :calibrate)
      (send self :set-val 'loop-enable nil)
      (send self :set-arm-val :larm :loop-enable nil)
      (send self :set-arm-val :rarm :loop-enable nil)
      res))
  (:calib-larm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Calibrate button pressed." :wait t :volume 0.6)
      (send self :set-val 'loop-enable t)
      (send self :set-arm-val :larm :loop-enable t)
      (send self :calibrate :larm)
      (send self :set-val 'loop-enable nil)
      (send self :set-arm-val :larm :loop-enable nil)
      res))
  (:calib-rarm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Calibrate button pressed." :wait t :volume 0.6)
      (send self :set-val 'loop-enable t)
      (send self :set-arm-val :rarm :loop-enable t)
      (send self :calibrate :rarm)
      (send self :set-val 'loop-enable nil)
      (send self :set-arm-val :rarm :loop-enable nil)
      res))
  (:start-grasp-larm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Start grasp button pressed. Left arm starts grasping." :wait nil :volume 0.6)
      (send self :start-grasp :larm :wait t)
      res))
  (:start-grasp-rarm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Start grasp button pressed. Right arm starts grasping." :wait nil :volume 0.6)
      (send self :start-grasp :rarm :wait t)
      res))
  (:stop-grasp-larm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Stop grasp button pressed. Left arm stops grasping." :wait nil :volume 0.6)
      (send self :stop-grasp :larm :wait t)
      res))
  (:stop-grasp-rarm-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Stop grasp button pressed. Right arm stops grasping." :wait nil :volume 0.6)
      (send self :stop-grasp :rarm :wait t)
      res))
  (:toggle-grasp-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Toggle grasp button pressed." :wait nil :volume 0.6)
      (send self :set-val 'gripper-button-toggle-p t)
      res))
  (:hold-grasp-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Hold grasp button pressed." :wait nil :volume 0.6)
      (send self :set-val 'gripper-button-toggle-p nil)
      res))
  ;; motion methods
  (:get-arm-val (arm name)
    (if (not (or (eq arm :larm) (eq arm :rarm)))
      (progn
        (ros::ros-error (format nil "Invalid args: (send self :get-arm-val ~A ~A)" arm name))
        (return-from :get-arm-val nil)))
    (let ((valname (format nil "~A-~A" (string-upcase arm) (string-upcase name))))
      (if (find (read-from-string valname) (mapcar #'car (cdr (send self :slots))))
        (send self :get-val (intern valname)))
      ))
  (:set-arm-val (arm name val)
    (if (not (or (eq arm :larm) (eq arm :rarm)))
      (progn
        (ros::ros-error (format nil "Invalid args: (send self :set-arm-val: ~A ~A ~A)" arm name val))
        (return-from :set-arm-val nil)))
    (let ((valname (format nil "~A-~A" (string-upcase arm) (string-upcase name))))
      (send self :set-val (intern valname) val)
      ))
  (:get-arm-controller (arm)
    (cond
      ((eq arm :larm) :larm-controller)
      ((eq arm :rarm) :rarm-controller)
      (t nil)))
  (:get-opposite-arm (arm)
    (cond
      ((eq arm :larm) :rarm)
      ((eq arm :rarm) :larm)
      (t nil)))
  (:angle-vector (&rest args)
    (send* robot-interface :angle-vector args))
  (:inverse-kinematics (arm target-coords &rest args)
    (if (eq arm :arms)
      (send* robot :inverse-kinematics target-coords :rotation-axis (list t t)
             :move-target (list (send robot :larm :end-coords) (send robot :rarm :end-coords))
             :revert-if-fail nil :stop ik-stop-step :debug-view nil args)
      (send* robot :inverse-kinematics target-coords :rotation-axis t
             :move-target (send robot arm :end-coords)
             :revert-if-fail nil :stop ik-stop-step :debug-view nil args)))
  (:start-grasp (arm &key (wait t))
     (send robot-interface :start-grasp arm :wait wait))
  (:stop-grasp (arm &key (wait t))
     (send robot-interface :stop-grasp arm :wait wait))
  (:filter-unsafe-target-coords (arm target-coords)
    (if (not target-coords) (return-from :filter-unsafe-target-coords nil))
    (let ((target-worldpos (send target-coords :worldpos))
          (current-end-coords (send self :get-arm-val arm :current-end-coords)))
      (if (not current-end-coords) (return-from :filter-unsafe-target-coords nil))
      (let ((end-coords-pos-diff
              (norm (v- target-worldpos (send current-end-coords :worldpos))))
            (target-coords-x (elt target-worldpos 0))
            (target-coords-y (elt target-worldpos 1))
            (target-coords-z (elt target-worldpos 2)))
        (cond
          ((> end-coords-pos-diff end-coords-pos-diff-thresh)
            (send self :send-joy-feedback arm)
            (ros::ros-error "arm ~A target-coords is too far from current position: ~A > ~A"
                            arm end-coords-pos-diff end-coords-pos-diff-thresh)
            (send self :set-arm-val arm :track-error-p t)
            nil)
          ((or (and target-coords-max-x (> target-coords-x target-coords-max-x))
               (and target-coords-min-x (> target-coords-min-x target-coords-x)))
            (send self :send-joy-feedback arm)
            (ros::ros-error "arm ~A target-coords is out of workspace: ~A > ~A > ~A"
                            arm target-coords-max-x target-coords-x target-coords-min-x)
            (send self :set-arm-val arm :track-error-p t)
            nil)
          ((or (and target-coords-max-y (> target-coords-y target-coords-max-y))
               (and target-coords-min-y (> target-coords-min-y target-coords-y)))
            (send self :send-joy-feedback arm)
            (ros::ros-error "arm ~A target-coords is out of workspace: ~A > ~A > ~A"
                            arm target-coords-max-y target-coords-y target-coords-min-y)
            (send self :set-arm-val arm :track-error-p t)
            nil)
          ((or (and target-coords-max-z (> target-coords-z target-coords-max-z))
               (and target-coords-min-z (> target-coords-min-z target-coords-z)))
            (send self :send-joy-feedback arm)
            (ros::ros-error "arm ~A target-coords is out of workspace: ~A > ~A > ~A"
                            arm target-coords-max-z target-coords-z target-coords-min-z)
            (send self :set-arm-val arm :track-error-p t)
            nil)
          (t
            (send self :set-arm-val arm :track-error-p nil)
            target-coords)))))
  (:filter-use-torso (arm-coords)
    (let ((larm-current-z (elt (send larm-current-end-coords :worldpos) 2))
          (larm-target-z (elt (send (car arm-coords) :worldpos) 2))
          (rarm-current-z (elt (send rarm-current-end-coords :worldpos) 2))
          (rarm-target-z (elt (send (cadr arm-coords) :worldpos) 2)))
      (or (> (abs (- larm-current-z larm-target-z)) torso-z-thresh)
          (> (abs (- rarm-current-z rarm-target-z)) torso-z-thresh))))
  (:get-mirror-pos (target-pos)
     (float-vector (elt target-pos 0) (* -1.0 (elt target-pos 1)) (elt target-pos 2)))
  (:get-mirror-rot (target-rot)
     (let* ((mirror-coords (make-coords :rot target-rot))
            (rpy-angle (car (send mirror-coords :rpy-angle))))
       (setf (elt rpy-angle 0) (* -1.0 (elt rpy-angle 0)))
       (setf (elt rpy-angle 2) (* -1.0 (elt rpy-angle 2)))
       (setq mirror-coords (make-coords :rpy rpy-angle))
       (send mirror-coords :worldrot)))
  (:get-target-coords (arm &key (head t) (mirror nil))
    (ros::ros-error ":get-target-coords is not implemented yet.")
    nil)
  (:get-target-coords-from-pos-rot (target-pos target-rot &key (head t) (mirror nil))
    (let* ((head-coords (send self :get-head-end-coords))
           (robot-height (elt (send head-coords :worldpos) 2))
           target-coords)
      (if (and target-pos target-rot)
        (progn
          (if mirror
            (progn
              (setq target-pos (send self :get-mirror-pos target-pos))
              (setq target-rot (send self :get-mirror-rot target-rot))))
          (setq target-coords
                (make-coords :pos (float-vector
                                    (+ head->shoulder-x-distance (* scale (elt target-pos 0)))
                                    (* scale (elt target-pos 1))
                                    (if head
                                      (+ robot-height (* scale (- (elt target-pos 2) robot-height)))
                                      (+ (- robot-height head->shoulder-z-distance)
                                         (* scale (elt target-pos 2)))))
                             :rot target-rot))))
      target-coords))
  (:arm-cb (arm &key (head t) (torso t) (safe t) (mirror nil))
    (if (eq arm :arms)
      (let* ((larm-raw-target-coords
               (if larm-loop-enable (send self :get-target-coords :larm :head head :mirror mirror)))
             (larm-target-coords-safe
               (if safe (send self :filter-unsafe-target-coords :larm larm-raw-target-coords)
                 larm-raw-target-coords))
             (rarm-raw-target-coords
               (if rarm-loop-enable (send self :get-target-coords :rarm :head head :mirror mirror)))
             (rarm-target-coords-safe
               (if safe (send self :filter-unsafe-target-coords :rarm rarm-raw-target-coords)
                 rarm-raw-target-coords))
             (larm-command-target-coords
               (if (and always-command-current-coords (null larm-raw-target-coords))
                 (send self :get-arm-val :larm :current-end-coords)
                 larm-raw-target-coords))
             (rarm-command-target-coords
               (if (and always-command-current-coords (null rarm-raw-target-coords))
                 (send self :get-arm-val :rarm :current-end-coords)
                 rarm-raw-target-coords))
             (target-coords-pair
               (cond ((and larm-command-target-coords rarm-command-target-coords)
                      (list larm-command-target-coords rarm-command-target-coords))
                     ((and larm-command-target-coords (not rarm-command-target-coords))
                      (list larm-command-target-coords
                            (send self :get-arm-val :rarm :current-end-coords)))
                     ((and (not larm-command-target-coords) rarm-command-target-coords)
                      (list (send self :get-arm-val :larm :current-end-coords)
                            rarm-command-target-coords))
                     (t nil))))
        (if arm-cb-solve-ik
          ;; TODO: always-command-current-coords t + arm-cb-solve-ik t not tested
          (progn
            (if always-command-current-coords (setq larm-target-coords-safe t))
            (if always-command-current-coords (setq rarm-target-coords-safe t))
            (if target-coords-pair
              (progn
                (setq torso (and torso (send self :filter-use-torso target-coords-pair)))
                (send self :inverse-kinematics :arms target-coords-pair
                      :use-torso
                      (if (and torso
                               larm-raw-target-coords
                               rarm-raw-target-coords)
                        torso-ik-weight)))
              (setq target-coords-pair (list nil nil)))
            (if loop-enable
              (cond
                ((and larm-target-coords-safe rarm-target-coords-safe)
                 (send self :angle-command-vector :arms :torso torso))
                ((and larm-target-coords-safe (not rarm-target-coords-safe))
                 (send self :angle-command-vector :larm :torso torso))
                ((and (not larm-target-coords-safe) rarm-target-coords-safe)
                 (send self :angle-command-vector :rarm :torso torso))
                (t nil))))
          (progn
            (send self :update-robot-model)
            (if always-command-current-coords (setq larm-target-coords-safe t))
            (if always-command-current-coords (setq rarm-target-coords-safe t))
            (if (and loop-enable target-coords-pair)
              (send self :publish-command-pose
                    (list (if larm-target-coords-safe (car target-coords-pair))
                          (if rarm-target-coords-safe (cadr target-coords-pair)))))))
        target-coords-pair)
      (let* ((raw-target-coords
               (if (send self :get-arm-val arm :loop-enable)
                 (send self :get-target-coords arm :head head :mirror mirror)))
             (opposite-arm-coords
               (send self :get-arm-val (send self :get-opposite-arm arm)
                     :current-end-coords))
             (target-coords-safe
               (if safe (send self :filter-unsafe-target-coords arm raw-target-coords)
                 raw-target-coords))
             (command-target-coords
               (if (and always-command-current-coords (null raw-target-coords))
                 (send self :get-arm-val arm :current-end-coords)
                 raw-target-coords))
             (target-coords-pair
               (cond ((and command-target-coords (eq arm :larm))
                      (list command-target-coords opposite-arm-coords))
                     ((and command-target-coords (eq arm :rarm))
                      (list opposite-arm-coords command-target-coords))
                     (t nil))))
        (if arm-cb-solve-ik
          ;; TODO: always-command-current-coords t + arm-cb-solve-ik t not tested
          (progn
            (if target-coords-pair
              (progn
                (send self :inverse-kinematics :arms target-coords-pair :use-torso nil))
              (setq target-coords-pair (list nil nil)))
            (if (and loop-enable target-coords-safe)
              (send self :angle-command-vector arm :torso nil)))
          (progn
            (if always-command-current-coords (setq target-coords-safe t))
            (send self :update-robot-model)
            (if (and loop-enable target-coords-safe target-coords-pair)
              (send self :publish-command-pose target-coords-pair))))
        target-coords-pair)))
  (:angle-command-vector (arm &key (torso t))
    (cond
      ((equal arm :arms)
       (send self :angle-vector (send robot :angle-vector)
             av-tm (send self :get-arm-controller :larm) 0
             :min-time min-time :scale av-scale)
       (send self :angle-vector (send robot :angle-vector)
             av-tm (send self :get-arm-controller :rarm) 0
             :min-time min-time :scale av-scale)
       (if torso
         (send self :angle-vector (send robot :angle-vector)
               torso-av-tm :torso-controller 0
               :min-time torso-min-time :scale torso-av-scale)))
      ((equal arm :larm)
       (send self :angle-vector (send robot :angle-vector)
             av-tm (send self :get-arm-controller :larm) 0
             :min-time min-time :scale av-scale)
       (if torso
         (send self :angle-vector (send robot :angle-vector)
               torso-av-tm :torso-controller 0
               :min-time torso-min-time :scale torso-av-scale)))
      ((equal arm :rarm)
       (send self :angle-vector (send robot :angle-vector)
             av-tm (send self :get-arm-controller :rarm) 0
             :min-time min-time :scale av-scale)
       (if torso
         (send self :angle-vector (send robot :angle-vector)
               torso-av-tm :torso-controller 0
               :min-time torso-min-time :scale torso-av-scale)))
      (t nil)))
  (:publish-command-pose (target-coords-pair)
    (if (car target-coords-pair)
      (ros::publish larm-command-pose-topic-name
        (ros::coords->tf-pose-stamped (car target-coords-pair) "")))
    (if (cadr target-coords-pair)
      (ros::publish rarm-command-pose-topic-name
        (ros::coords->tf-pose-stamped (cadr target-coords-pair) ""))))
  (:get-head-end-coords ()
    (send (send robot :head :end-coords) :copy-worldcoords))
  (:head-cb ()
    (let ((ypr-angle (send self :get-head-ypr-angle)))
      (if ypr-angle
        (send self :move-head (elt ypr-angle 0) (elt ypr-angle 1) (elt ypr-angle 2)))))
  (:move-head (yaw pitch roll)
    (send robot :head-neck-p :joint-angle (rad2deg pitch))
    (send robot :head-neck-y :joint-angle (rad2deg yaw))
    (send self :angle-vector (send robot :angle-vector) av-tm
          :head-controller 0 :min-time min-time :scale av-scale))
  (:controller-button-p (arm button &key (button-toggle t))
    (let ((controller-button-method
            (read-from-string (format nil ":controller-~A-button-p" (string-downcase button)))))
      (if (find-method self controller-button-method)
        (send self controller-button-method arm :button-toggle button-toggle)
        (progn
          (ros::ros-error (format nil "cannot find method: ~A" controller-button-method))
          nil))))
  (:controller-button-common-p (button &key (button-toggle t))
    (let* ((button-prefix (subseq (format nil "~A" button) 0 5))
           (prev-button
             (if (or (equal button-prefix "larm-")
                     (equal button-prefix "rarm-"))
               (read-from-string
                 (format nil "~Aprev-~A" button-prefix (subseq (format nil "~A" button) 5)))
               (read-from-string (format nil "prev-~A" button))))
           (button-counter (read-from-string (format nil "~A-count" button)))
           (button-wait-counter
             (read-from-string
               (format nil "~A-wait-count"
                       (if (or (equal button-prefix "larm-")
                               (equal button-prefix "rarm-"))
                         (subseq (format nil "~A" button) 5)
                         button))))
           (button-p (send self :get-val button))
           (prev-button-p (send self :get-val prev-button))
           (button-count (send self :get-val button-counter))
           (button-wait-count (send self :get-val button-wait-counter))
           (controller-button-p (and (not (eq button-p prev-button-p))
                                     (if button-toggle button-p t))))
      (if button-toggle
        (if (> button-count 0)
          (progn
            (send self :set-val button-counter (- button-count 1))
            nil)
          (progn
            (if controller-button-p
              (progn
                (send self :set-val button-counter button-wait-count)
                (cons controller-button-p button-p)))))
        (if controller-button-p (cons controller-button-p button-p)))))
  (:gripper-cb (arm &key (mirror nil) (button :trigger))
    (let ((gripper-button-p
            (send self :controller-button-p
                  (if mirror (send self :get-opposite-arm arm) arm) button
                  :button-toggle gripper-button-toggle-p))
          (grasp-p (send self :get-arm-val arm :grasp)))
      (if gripper-button-p
        (progn
          (if (if gripper-button-toggle-p grasp-p (null (cdr gripper-button-p)))
            (send self :stop-grasp arm :wait nil)
            (send self :start-grasp arm :wait nil))
          (send self :set-arm-val arm :grasp
                (if gripper-button-toggle-p (not grasp-p) (cdr gripper-button-p)))))))
  (:gripper-status-cb (arm msg)
    (let ((grasping-p (some #'(lambda (x) (eq x 1)) (send-all (send msg :status_list) :status)))
          (prev-grasping-p (send self :get-arm-val arm :grasping-p))
          (grasp-start-time (send self :get-arm-val arm :grasp-start-time))
          (grasp-timeout-p nil))
      (if (and grasping-p (not prev-grasping-p))
        (send robot-interface :cancel-angle-vector
              :controller-type (send self :get-arm-controller arm)))
      (if (and grasp-start-time (not grasping-p)) (setq grasp-start-time nil))
      (if (and grasping-p grasp-timeout-time)
        (progn
          (if (not grasp-start-time) (setq grasp-start-time (ros::time-now)))
          (setq grasp-timeout-p
                (> (- (send (ros::time-now) :to-nsec) (send grasp-start-time :to-nsec))
                   (* grasp-timeout-time 1e9)))))
      (if (and grasping-p grasp-timeout-p)
        (ros::ros-error "grasp timeout for ~A seconds: ~A" grasp-timeout-time arm))
      (send self :set-arm-val arm :grasping-p grasping-p)
      (send self :set-arm-val arm :grasp-start-time grasp-start-time)
      (send self :set-arm-val arm :grasp-timeout-p grasp-timeout-p)))
  (:collision-status-cb (arm msg)
    (let ((collision-p (send msg :collision_state)))
      (if collision-p
        (progn
          (send self :send-joy-feedback arm)
          (ros::ros-error "arm ~A collision detected, stopped" arm)))
      (send self :set-arm-val arm :collision-p collision-p)))
  (:coords->pose-stamped (coords)
    (let ((msg (instance geometry_msgs::PoseStamped :init))
          (rot (send coords :worldrot))
          (pos (send coords :worldpos)))
      (send msg :header :frame_id base-frame-id)
      (send msg :pose :position (ros::pos->tf-translation pos))
      (send msg :pose :orientation (ros::rot->tf-quaternion rot))
      msg))
  (:generate-eus-vive-status-msg ()
    (let ((eus-vive-status-msg (instance eus_vive::EusViveStatusArray :init))
          (now (ros::time-now))
          (larm-status-msg (instance eus_vive::EusViveStatus :init))
          (rarm-status-msg (instance eus_vive::EusViveStatus :init)))
      (send eus-vive-status-msg :header :stamp now)
      (send larm-status-msg :header :stamp now)
      (send larm-status-msg :part_name (string-downcase :larm))
      (send larm-status-msg :enable (send self :get-arm-val :larm :enable))
      (send larm-status-msg :collision (send self :get-arm-val :larm :collision-p))
      (send larm-status-msg :track_error (send self :get-arm-val :larm :track-error-p))
      (send larm-status-msg :hand_close (send self :get-arm-val :larm :grasp))
      (send rarm-status-msg :header :stamp now)
      (send rarm-status-msg :part_name (string-downcase :rarm))
      (send rarm-status-msg :enable (send self :get-arm-val :rarm :enable))
      (send rarm-status-msg :collision (send self :get-arm-val :rarm :collision-p))
      (send rarm-status-msg :track_error (send self :get-arm-val :rarm :track-error-p))
      (send rarm-status-msg :hand_close (send self :get-arm-val :rarm :grasp))
      (send eus-vive-status-msg :status (list larm-status-msg rarm-status-msg))
      eus-vive-status-msg))
  (:visualize (arm-coords)
    (let ((camera-draw-object-list draw-object-list)
          (eus-vive-status-msg (send self :generate-eus-vive-status-msg))
          larm-cube larm-coords rarm-cube rarm-coords)
      (setq larm-coords (car arm-coords))
      (if larm-coords
        (progn
          (ros::publish larm-coords-visualize-topic-name
                        (send self :coords->pose-stamped larm-coords))
          (send larm-coords :draw-on :flush t :size 50 :width 5 :color #f(0 1 0))
          (setq larm-cube (make-cube 100 100 100))
          (if (or (send self :get-arm-val :larm :collision-p)
                  (send self :get-arm-val :larm :track-error-p))
            (send larm-cube :set-color :red)
            (send larm-cube :set-color :green))
          (send larm-cube :4x4 (send larm-coords :4x4))
          (setq camera-draw-object-list (append camera-draw-object-list (list larm-cube)))))
      (setq rarm-coords (cadr arm-coords))
      (if rarm-coords
        (progn
          (ros::publish rarm-coords-visualize-topic-name
                        (send self :coords->pose-stamped rarm-coords))
          (send rarm-coords :draw-on :flush t :size 50 :width 5 :color #f(1 0 0))
          (setq rarm-cube (make-cube 100 100 100))
          (if (or (send self :get-arm-val :rarm :collision-p)
                  (send self :get-arm-val :rarm :track-error-p))
            (send rarm-cube :set-color :red)
            (send rarm-cube :set-color :blue))
          (send rarm-cube :4x4 (send rarm-coords :4x4))
          (setq camera-draw-object-list (append camera-draw-object-list (list rarm-cube)))))
      (ros::publish robot-state-visualize-topic-name
                    (angle-vector-to-display-robot-state
                      robot (send (send robot :link base-frame-id) :copy-worldcoords)))
      (ros::publish eus-vive-status-topic-name eus-vive-status-msg)
      (ros::publish larm-grasp-visualize-topic-name
                    (instance std_msgs::Float32 :init :data
                              (if (send self :get-arm-val :larm :grasp) 0.0 1.0)))
      (ros::publish rarm-grasp-visualize-topic-name
                    (instance std_msgs::Float32 :init :data
                              (if (send self :get-arm-val :rarm :grasp) 0.0 1.0)))
      (send *irtviewer* :draw-objects)
      (send camera-model :draw-objects camera-draw-object-list)
      (ros::publish irtviewer-visualize-topic-name
                    (ros::image->sensor_msgs/Image (send camera-model :get-image)))
      (x::window-main-one)))
  (:enable-cb (&key (mirror nil) (button :menu))
    (send self :loop-enable-arm :larm :mirror mirror :button button)
    (send self :loop-enable-arm :rarm :mirror mirror :button button))
  (:loop-enable-arm (arm &key (mirror nil) (button :menu))
    (let ((enable-button-p
            (send self :controller-button-p
                  (if mirror (send self :get-opposite-arm arm) arm) button
                  :button-toggle t))
          (enable-p (send self :get-arm-val arm :enable)))
      (if enable-button-p
        (progn
          (if enable-p
            (progn
              (send robot-interface :cancel-angle-vector
                    :controller-type (send self :get-arm-controller arm))
              (if (find-method robot-interface :torso-controller)
                (send robot-interface :cancel-angle-vector :controller-type :torso-controller))
              (send self :set-arm-val arm :track-error-p nil)
              (send self :set-arm-val arm :collision-p nil)
              ; (send robot-interface :speak
              ;       (format nil "Disable ~A arm"
              ;               (if mirror (if (eq arm :larm) "right" "left")
              ;                 (if (eq arm :larm) "left" "right")))
              ;       :wait nil :volume 0.8)
              (ros::ros-info "arm: ~A stopping" arm))
            (progn
              (send robot :angle-vector (send robot-interface :state :potentio-vector))
              ; (send robot-interface :speak
              ;       (format nil "Enable ~A arm"
              ;               (if mirror (if (eq arm :larm) "right" "left")
              ;                 (if (eq arm :larm) "left" "right")))
              ;       :wait nil :volume 0.8)
              (ros::ros-info "arm: ~A starting" arm)))
          (send self :set-arm-val arm :enable (not enable-p))
          (send self :send-joy-feedback arm)))))
  (:update-robot-model ()
    (send robot :angle-vector (send robot-interface :state :potentio-vector)))
  (:update-current-end-coords ()
     (let ((av (send robot :angle-vector)))
       (send robot :angle-vector
             (send robot-interface :state :potentio-vector))
       (send self :set-arm-val :larm :current-end-coords
             (send robot :larm :end-coords :copy-worldcoords))
       (send self :set-arm-val :rarm :current-end-coords
             (send robot :rarm :end-coords :copy-worldcoords))
       (send robot :angle-vector av)))
  (:set-reference-end-coords (arm &key (update-robot-model t))
    (if update-robot-model (send self :update-robot-model))
    (if (send robot arm :end-coords)
      (send self :set-arm-val arm :ref-end-coords
            (send (send robot arm :end-coords) :copy-worldcoords)))
    t)
  (:grasping-p (arm)
     (and (send self :get-arm-val arm :grasping-p)
          (not (send self :get-arm-val arm :grasp-timeout-p))))
  ;; arm motion cb
  (:arm-motion-cb
    (&key (head t) (torso t) (safe t) (mirror nil)
          (gripper-button :trigger) &allow-other-keys)
    (let ((visualize-arm-coords (list nil nil)))
      (if (and torso (not (or (send self :grasping-p :larm) (send self :grasping-p :rarm))))
        (cond
          ((and larm-enable rarm-enable)
           (send self :gripper-cb :larm :mirror mirror :button gripper-button)
           (send self :gripper-cb :rarm :mirror mirror :button gripper-button)
           (setq visualize-arm-coords
                 (send self :arm-cb :arms :head head :torso torso :safe safe :mirror mirror)))
          ((and larm-enable (not rarm-enable))
           (send self :gripper-cb :larm :mirror mirror :button gripper-button)
           (setq visualize-arm-coords
                 (send self :arm-cb :larm :head head :torso torso :safe safe :mirror mirror)))
          ((and (not larm-enable) rarm-enable)
           (send self :gripper-cb :rarm :mirror mirror :button gripper-button)
           (setq visualize-arm-coords
                 (send self :arm-cb :rarm :head head :torso torso :safe safe :mirror mirror)))
          (t nil))
        (progn
          (if (and larm-enable (not (send self :grasping-p :larm)))
            (progn
              (send self :gripper-cb :larm :mirror mirror :button gripper-button)
              (setq visualize-arm-coords
                    (send self :arm-cb :larm :head head :torso nil :safe safe :mirror mirror))))
          (if (and rarm-enable (not (send self :grasping-p :rarm)))
            (progn
              (send self :gripper-cb :rarm :mirror mirror :button gripper-button)
              (setq visualize-arm-coords
                    (send self :arm-cb :rarm :head head :torso nil :safe safe :mirror mirror))))))
      visualize-arm-coords))
  ;; motion cb
  (:motion-cb (&key (head t) (torso t) (safe-arm t) (mirror nil) (gripper-button :trigger))
    (let (visualize-arm-coords)
      (cond
        ((or larm-enable rarm-enable)
         (setq visualize-arm-coords
               (send self :arm-motion-cb :head head :torso torso :safe safe-arm :mirror mirror
                     :gripper-button gripper-button)))
        (t nil))
      visualize-arm-coords))
  ;; main loop step
  (:main-loop-step (&key (head t) (torso t) (safe-arm t) (mirror nil)
                         (enable-button :menu) (gripper-button :trigger) (visualize t))
    (let (visualize-arm-coords)
      (send self :enable-cb :mirror mirror :button enable-button)
      (setq visualize-arm-coords
            (send self :motion-cb :head head :torso torso :safe-arm safe-arm :mirror mirror
                  :gripper-button gripper-button))
      (if (and head loop-enable) (send self :head-cb))
      (send self :update-current-end-coords)
      (if visualize (send self :visualize visualize-arm-coords))))
  ;; main loop
  (:main-loop (&rest args)
    (ros::rate rate)
    (send self :update-current-end-coords)
    (send *ri* :speak "I'm ready to start demo." :wait nil :volume 0.6)
    (while (ros::ok)
      (if loop-enable (send* self :main-loop-step args))
      (send *irtviewer* :draw-objects)
      (ros::spin-once)
      (ros::sleep)))
  ;; place holders
  (:calib-controller ()
    (return-from :calib-controller t))
  (:send-joy-feedback (arm)
    (return-from :send-joy-feedback nil))
  (:get-head-ypr-angle ()
    (return-from :get-head-ypr-angle nil)))


(provide :robot-vr-interface)
