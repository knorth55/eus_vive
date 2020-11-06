;; -*- mode: lisp;-*-
(ros::load-ros-manifest "baxter_core_msgs")

(require :baxter-interface "package://eus_vive/euslisp/lib/baxter-interface.l")
(require :robot-oculus-interface "package://eus_vive/euslisp/lib/robot-oculus-interface.l")


(defclass baxter-oculus-interface
  :super robot-oculus-interface
  :slots ())


(defmethod baxter-oculus-interface
  (:init (&rest args)
    (send self :set-val 'robot *baxter*)
    (send self :set-val 'robot-interface *ri*)
    (send self :set-val 'camera-model *camera-model*)
    (send self :set-val 'rate 10)
    (send self :set-val 'end-coords-pos-diff-thresh 400)
    (send self :set-val 'draw-object-list (list *baxter* *background-cube*))
    ;; for oculus
    (send self :set-val 'hmd-pose-topic-name "/oculus/hmd/pose_stamped")
    (send self :set-val 'left-controller-pose-topic-name "/oculus/left_controller/pose_stamped")
    (send self :set-val 'right-controller-pose-topic-name "/oculus/right_controller/pose_stamped")
    ;; for baxter
    (send self :set-val 'base-frame-id "base")
    (send self :set-val 'head-frame-id "head")
    (send self :set-val 'ik-stop-step 10)
    (send self :set-val 'scale 3.0)
    (send self :set-val 'av-tm 300)
    (send self :set-val 'av-scale 3.0)
    (send self :set-val 'min-time 0.3)
    (send self :set-val 'grasp-timeout-time 1.5)
    (send self :set-val 'arm-length 1000)
    (send self :set-val 'head->shoulder-x-distance -100)
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
      (send self :stop-grasp :arms :wait nil)
      (send self :angle-vector (send robot :reset-teleop-pose) 5000)
      (send robot-interface :wait-interpolation)
      res))
  (:move-head (yaw pitch roll)
    ;; no pitch joint
    (send robot :head-neck-y :joint-angle (rad2deg yaw))
    (send self :angle-vector (send robot :angle-vector) av-tm
          :head-controller 0 :min-time min-time :scale av-scale))
  (:get-head-end-coords ()
    (let (coords)
      (send tfl :wait-for-transform base-frame-id head-frame-id (ros::time 0) 0.1)
      (setq coords (send tfl :lookup-transform base-frame-id head-frame-id (ros::time 0)))
      (if coords (send coords :rotate pi/2 :y :world))
      coords))
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


(defun baxter-oculus-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
  (eus_vive::baxter-init :lgripper lgripper :rgripper rgripper)
  (objects (list *baxter*))
  (setq *camera-model*
        (make-camera-from-param :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
                                :name "camera"))
  (send *camera-model* :translate #f(1500 0 600))
  (send *camera-model* :rotate -pi/2 :y :world)
  (send *camera-model* :rotate -pi/2 :x :world)
  (send *camera-model* :rotate -0.30 :y :world)
  (send *irtviewer* :change-background (float-vector 1 1 1))
  (send *irtviewer* :draw-floor 100)
  (send *irtviewer* :floor-color #f(0 0 0))
  (setq *background-cube* (make-cube 10 6000 6000))
  (send *background-cube* :set-color #f(1 1 1))
  (send *background-cube* :translate #f(-1000 0 0))
  (setq *ti* (instance baxter-oculus-interface :init :loop-enable loop-enable
                       :lgripper lgripper :rgripper rgripper)))


(defun signal-hook (sig code)
  (if (boundp '*ri*)
    (progn
      (ros::ros-info "cancel larm controller")
      (send *ri* :cancel-angle-vector :controller-type :larm-controller)
      (ros::ros-info "cancel rarm controller")
      (send *ri* :cancel-angle-vector :controller-type :rarm-controller)))
  (reset))


(unix:signal 2 'signal-hook)
(unix:signal 15 'signal-hook)
