;; -*- mode: lisp;-*-
(ros::load-ros-manifest "baxter_core_msgs")

(load "package://baxtereus/baxter-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")


(defmethod baxter-robot
  (:reset-teleop-pose ()
    (send self :angle-vector
          (float-vector 0.0 -5.55908 -77.7612 -10.0854 120.081 40.0122 -44.4067 -29.2017
                        5.55908 -77.7612 10.0854 120.081 -40.0122 -44.4067 29.2017))))


(defclass baxter-vive-interface
  :super robot-vive-interface
  :slots ())


(defmethod baxter-vive-interface
  (:init (&rest args)
    (send self :set-val 'robot *baxter*)
    (send self :set-val 'robot-interface *ri*)
    (send self :set-val 'camera-model *camera-model*)
    (send self :set-val 'rate 10)
    (send self :set-val 'trigger-wait-count 5)
    (send self :set-val 'menu-wait-count 5)
    (send self :set-val 'trackpad-wait-count 5)
    (send self :set-val 'grip-wait-count 5)
    (send self :set-val 'end-coords-pos-diff-thresh 400)
    (send self :set-val 'draw-object-list (list *baxter* *background-cube*))
    ;; for vive
    (send self :set-val 'hmd-frame-id "hmd")
    (send self :set-val 'bvive-frame-id "lighthouse_LHB_8E924CC3")
    (send self :set-val 'cvive-frame-id "lighthouse_LHB_11CFA4E1")
    (send self :set-val 'larm-vive-frame-id "controller_LHR_FD35BD42")
    (send self :set-val 'rarm-vive-frame-id "controller_LHR_F7AFBF47")
    (send self :set-val 'feedback-topic-name "/vive/set_feedback")
    ;; for workspace
    (send self :set-val 'target-coords-max-x 1300.0)
    (send self :set-val 'target-coords-max-y 750.0)
    (send self :set-val 'target-coords-max-z 1200.0)
    (send self :set-val 'target-coords-min-x 300.0)
    (send self :set-val 'target-coords-min-y -750.0)
    (send self :set-val 'target-coords-min-z 0.0)
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
    (send-super* :init args))
  (:reset-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send-super :reset-service req)
      (send robot-interface :stop-grasp :arms :wait nil)
      (send self :angle-vector (send robot :reset-teleop-pose) 5000)
      (send robot-interface :wait-interpolation)
      res))
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


(defun baxter-vive-init (&key (loop-enable t))
  (baxter-init)
  (objects (list *baxter*))
  (setq *camera-model*
        (make-camera-from-param :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
                                :name "camera"))
  (send *camera-model* :translate #f(1500 0 600))
  (send *camera-model* :rotate -1.57 :y :world)
  (send *camera-model* :rotate -1.57 :x :world)
  (send *camera-model* :rotate -0.30 :y :world)
  (send *irtviewer* :change-background (float-vector 1 1 1))
  (send *irtviewer* :draw-floor 100)
  (send *irtviewer* :floor-color #f(0 0 0))
  (setq *background-cube* (make-cube 10 6000 6000))
  (send *background-cube* :set-color #f(1 1 1))
  (send *background-cube* :translate #f(-1000 0 0))
  (setq *ti* (instance baxter-vive-interface :init :loop-enable loop-enable)))


(defun signal-hook (sig code)
  (when (boundp '*ri*)
    (ros::ros-info "cancel larm controller")
    (send *ri* :cancel-angle-vector :controller-type :larm-controller)
    (ros::ros-info "cancel rarm controller")
    (send *ri* :cancel-angle-vector :controller-type :rarm-controller))
  (reset))


(unix:signal 2 'signal-hook)
(unix:signal 15 'signal-hook)
