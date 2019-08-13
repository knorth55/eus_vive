;; -*- mode: lisp;-*-
(ros::load-ros-manifest "baxter_core_msgs")

(load "package://baxtereus/baxter-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")

(defclass baxter-vive-interface
  :super robot-vive-interface
  :slots ())


(defmethod baxter-vive-interface
  (:init ()
    (send self :set-val 'robot *baxter*)
    (send self :set-val 'robot-interface *ri*)
    (send self :set-val 'rate 10)
    (send self :set-val 'trigger-wait-count 5)
    (send self :set-val 'menu-wait-count 5)
    (send self :set-val 'trackpad-wait-count 5)
    (send self :set-val 'grip-wait-count 5)
    (send self :set-val 'robot-state-visualize-topic-name "/display_robot_state")
    (send self :set-val 'end-coords-pos-diff-thresh 300)
    ;; for vive
    (send self :set-val 'hmd-frame-id "hmd")
    (send self :set-val 'bvive-frame-id "lighthouse_LHB_11CFA4E1")
    (send self :set-val 'cvive-frame-id "lighthouse_LHB_8E924CC3")
    (send self :set-val 'larm-vive-frame-id "controller_LHR_FD35BD42")
    (send self :set-val 'rarm-vive-frame-id "controller_LHR_F7AFBF47")
    (send self :set-val 'feedback-topic-name "/vive/set_feedback")
    ;; for baxter
    (send self :set-val 'base-frame-id "base")
    (send self :set-val 'ik-stop-step 10)
    (send self :set-val 'scale 3.0)
    (send self :set-val 'av-tm 300)
    (send self :set-val 'av-scale 3.0)
    (send self :set-val 'min-time 0.3)
    (send self :set-val 'grasp-timeout-time 1.5)
    (send self :set-val 'arm-length 1000)
    (send self :set-val 'head->shoulder-x-distance 0)
    (send self :set-val 'head->shoulder-z-distance 30)
    (send self :set-val 'gripper-status-topic-name
          '(format nil "/robot/end_effector/~A_gripper/gripper_action/status" (if (eq arm :larm) "left" "right")))
    (send self :set-val 'collision-status-topic-name
          '(format nil "/robot/limb/~A/collision_detection_state" (if (eq arm :larm) "left" "right")))
    (send self :set-val 'collision-status-topic-type baxter_core_msgs::CollisionDetectionState)
    (send-super :init))
  (:angle-vector (&rest args)
    (send* robot-interface :angle-vector-raw args))
  (:inverse-kinematics (arm target-coords &rest args)
    (if (eq arm :arms)
      (send* robot :inverse-kinematics-raw target-coords :rotation-axis (list t t)
             :move-target (list (send robot :larm :end-coords) (send robot :rarm :end-coords))
             :avoid-collision-distance 5 :revert-if-fail nil :stop ik-stop-step
             :debug-view nil args)
      (send* robot :inverse-kinematics-raw target-coords
             :rotation-axis t :move-target (send robot arm :end-coords)
             :avoid-collision-distance 5 :revert-if-fail nil :stop ik-stop-step
             :debug-view nil args))))


(defun baxter-vive-init ()
  (baxter-init)
  (objects (list *baxter*))
  (setq *ti* (instance baxter-vive-interface :init)))


(defun signal-hook (sig code)
  (when (boundp '*ri*)
    (send *ri* :cancel-angle-vector :controller-type :larm-controller)
    (send *ri* :cancel-angle-vector :controller-type :rarm-controller))
  (reset))


(unix:signal 2 'signal-hook)
(unix:signal 15 'signal-hook)
