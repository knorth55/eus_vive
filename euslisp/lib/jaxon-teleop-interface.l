;; -*- mode: lisp;-*-

(ros::roseus-add-msgs "geometry_msgs")

(require :jaxon-interface "package://hrpsys_ros_bridge_tutorials/euslisp/jaxon-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :robot-move-base-teleop-interface "package://eus_teleop/euslisp/lib/robot-move-base-teleop-interface.l")


(if (not (assoc :init-jaxon-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :init (send robot-teleop-interface :methods)) :init-jaxon-org))
(if (not (assoc :ros-init-jaxon-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :ros-init (send robot-teleop-interface :methods)) :ros-init-jaxon-org))
(if (not (assoc :publish-command-pose-jaxon-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :publish-command-pose (send robot-teleop-interface :methods))
          :publish-command-pose-jaxon-org))


(defmethod robot-teleop-interface
  (:init (&rest args)
    (prog1
      (send* self :init-jaxon-org args)
      (send self :set-val 'robot *jaxon*)
      (send self :set-val 'robot-interface *ri*)
      (send self :set-val 'camera-model *camera-model*)
      (send self :set-val 'rate 10)
      (send self :set-val 'end-coords-pos-diff-thresh 400)
      (send self :set-val 'draw-object-list (list *jaxon*))
      ;; jaxon frame
      (send self :set-val 'base-frame-id "BODY")
      (send self :set-val 'head-frame-id "HEAD_LINK1")
      ;; jaxon ik
      (send self :set-val 'arm-cb-solve-ik nil)
      (send self :set-val 'larm-command-pose-topic-name "/master_larm_pose_converted")
      (send self :set-val 'rarm-command-pose-topic-name "/master_rarm_pose_converted")
      (send self :set-val 'lleg-command-pose-topic-name "/master_lleg_pose_converted")
      (send self :set-val 'rleg-command-pose-topic-name "/master_rleg_pose_converted")
      (send self :set-val 'always-command-current-coords t)
      (send self :set-val 'larm-feedback-pose-topic-name "/slave_larm_pose")
      (send self :set-val 'rarm-feedback-pose-topic-name "/slave_rarm_pose")
      (send self :set-val 'lleg-feedback-pose-topic-name "/slave_lleg_pose")
      (send self :set-val 'rleg-feedback-pose-topic-name "/slave_rleg_pose")
      ;; jaxon gripper
      (send self :set-val 'grasp-timeout-time nil)
      ;; jaxon move base
      (send self :set-val 'vx-thresh 0.3)
      (send self :set-val 'vy-thresh 0.3)
      (send self :set-val 'vw-thresh 0.3)
      (send self :set-val 'vx-scale 1.0)
      (send self :set-val 'vy-scale 1.0)
      (send self :set-val 'vw-scale 1.0)
      (send self :set-val 'joy-deadman-button-index 10)
      (send self :set-val 'joy-torso-up-button-index 12)
      (send self :set-val 'joy-torso-down-button-index 14)
      (send self :set-val 'joy-unsafe-teleop-button-index 9)
      (send self :set-val 'joy-vx-axes-index 3)
      (send self :set-val 'joy-vy-axes-index 2)
      (send self :set-val 'joy-vw-axes-index 0)
      ;; jaxon hardware configuration
      (send self :set-val 'scale 1.5)
      (send self :set-val 'arm-length 600)
      (send self :set-val 'head->shoulder-x-distance 100)
      (send self :set-val 'head->shoulder-z-distance 50)

      (send self :set-arm-val :larm :gripper-status-topic-name
            "/jaxon/l_gripper_controller/status")
      (send self :set-arm-val :rarm :gripper-status-topic-name
            "/jaxon/r_gripper_controller/status")
      ))
  (:ros-init ()
    (prog1
      (send self :ros-init-jaxon-org)
      (ros::advertise larm-command-pose-topic-name geometry_msgs::PoseStamped)
      (ros::advertise rarm-command-pose-topic-name geometry_msgs::PoseStamped)
      (ros::advertise lleg-command-pose-topic-name geometry_msgs::PoseStamped)
      (ros::advertise rleg-command-pose-topic-name geometry_msgs::PoseStamped)
      (ros::subscribe larm-feedback-pose-topic-name geometry_msgs::PoseStamped
                      #'send self :ee-pose-topic-cb :larm)
      (ros::subscribe rarm-feedback-pose-topic-name geometry_msgs::PoseStamped
                      #'send self :ee-pose-topic-cb :rarm)
      (ros::subscribe lleg-feedback-pose-topic-name geometry_msgs::PoseStamped
                      #'send self :ee-pose-topic-cb :lleg)
      (ros::subscribe rleg-feedback-pose-topic-name geometry_msgs::PoseStamped
                      #'send self :ee-pose-topic-cb :rleg)))
  (:ee-pose-topic-cb (limb msg)
    (let ((ee-coords (ros::tf-pose-stamped->coords msg)))
      (cond
        ((equal limb :larm)
         (send self :set-val 'larm-current-end-coords ee-coords))
        ((equal limb :rarm)
         (send self :set-val 'rarm-current-end-coords ee-coords))
        ((equal limb :lleg)
         (send self :set-val 'lleg-current-end-coords ee-coords))
        ((equal limb :rleg)
         (send self :set-val 'rleg-current-end-coords ee-coords))
        (t nil))))
  (:publish-command-pose (target-coords-pair)
    (send self :publish-command-pose-jaxon-org target-coords-pair)
    (if lleg-current-end-coords
      (ros::publish lleg-command-pose-topic-name
        (ros::coords->tf-pose-stamped lleg-current-end-coords "")))
    (if rleg-current-end-coords
      (ros::publish rleg-command-pose-topic-name
        (ros::coords->tf-pose-stamped rleg-current-end-coords ""))))
  ;; do nothing
  (:update-current-end-coords ()
    t)
  )


(defun make-jaxon-irtviewer (&key (no-window t))
  (if (and no-window
           (string>= (car lisp-implementation-version) "9.28"))
    (make-irtviewer-no-window))
  (objects (list *jaxon*))
  (send *irtviewer* :change-background (float-vector 1 1 1))
  (send *irtviewer* :draw-floor 100)
  (send *irtviewer* :floor-color #f(0 0 0)))


(defun make-jaxon-camera-model (&key (no-window t))
  (setq *camera-model*
        (if (string>= (car lisp-implementation-version) "9.28")
          (make-camera-from-param
            :pwidth 640 :pheight 640 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t :no-window t)
          (make-camera-from-param
            :pwidth 640 :pheight 640 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t)))
  (send *camera-model* :translate #f(1500 0 800))
  (send *camera-model* :rotate -1.57 :y :world)
  (send *camera-model* :rotate -1.57 :x :world))


(defun signal-hook (sig code)
  (if (boundp '*ri*)
    (progn
      (ros::ros-info "cancel larm controller")
      (send *ri* :cancel-angle-vector :controller-type :larm-controller)
      (ros::ros-info "cancel rarm controller")
      (send *ri* :cancel-angle-vector :controller-type :rarm-controller)
      (ros::ros-info "cancel torso controller")
      (send *ri* :cancel-angle-vector :controller-type :torso-controller)))
  (if (and (boundp '*ti*) (find-method *ti* :switch-joy-to-ps3joy))
    (progn
      (ros::ros-info "switch joy from teleop device to ps3joy")
      (send *ti* :switch-joy-to-ps3joy)))
  (reset))


(unix:signal 2 'signal-hook)
(unix:signal 9 'signal-hook)
(unix:signal 15 'signal-hook)


(provide :jaxon-teleop-interface)
