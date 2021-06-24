;; -*- mode: lisp;-*-
(load "package://pr2eus/pr2-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(if (not (assoc :init-org (send robot-vr-interface :methods)))
  (rplaca (assoc :init (send robot-vr-interface :methods)) :init-org))
(if (not (assoc :reset-arm-org (send robot-vr-interface :methods)))
  (rplaca (assoc :reset-arm (send robot-vr-interface :methods)) :reset-arm-org))
(if (not (assoc :reset-torso-org (send robot-vr-interface :methods)))
  (rplaca (assoc :reset-torso (send robot-vr-interface :methods)) :reset-torso-org))


(defmethod robot-vr-interface
  (:init (&rest args)
    (send self :set-val 'robot *pr2*)
    (send self :set-val 'robot-interface *ri*)
    (send self :set-val 'camera-model *camera-model*)
    (send self :set-val 'rate 10)
    (send self :set-val 'end-coords-pos-diff-thresh 400)
    (send self :set-val 'draw-object-list (list *pr2*))
    ;; for pr2
    (send self :set-val 'base-frame-id "base_footprint")
    (send self :set-val 'head-frame-id "head_tilt_link")
    (send self :set-val 'ik-stop-step 10)
    (send self :set-val 'scale 1.5)
    (send self :set-val 'av-tm 300)
    (send self :set-val 'av-scale 5.0)
    (send self :set-val 'min-time 0.3)
    (send self :set-val 'torso-av-tm 500)
    (send self :set-val 'torso-av-scale 1.5)
    (send self :set-val 'torso-min-time 0.5)
    (send self :set-val 'torso-z-thresh 100)
    (send self :set-val 'torso-ik-weight 0.0001)
    (send self :set-val 'grasp-timeout-time nil)
    (send self :set-val 'arm-length 600)
    (send self :set-val 'head->shoulder-x-distance 100)
    (send self :set-val 'head->shoulder-z-distance 50)
    (send self :set-arm-val :larm :gripper-status-topic-name
          "/l_gripper_controller/gripper_action/status")
    (send self :set-arm-val :rarm :gripper-status-topic-name
          "/r_gripper_controller/gripper_action/status")
    (send* self :init-org args))
  (:angle-vector (&rest args)
    (send* robot-interface :angle-vector args))
  (:inverse-kinematics (arm target-coords &rest args)
    (if (eq arm :arms)
      (send* robot :inverse-kinematics target-coords :rotation-axis (list t t)
             :move-target (list (send robot :larm :end-coords) (send robot :rarm :end-coords))
             :avoid-collision-distance 5 :revert-if-fail nil :stop ik-stop-step
             :debug-view nil args)
      (send* robot :inverse-kinematics target-coords
             :rotation-axis t :move-target (send robot arm :end-coords)
             :avoid-collision-distance 5 :revert-if-fail nil :stop ik-stop-step
             :debug-view nil args)))
  (:start-grasp (arm &key (wait t))
    (send robot-interface :start-grasp arm :wait wait :gain (/ 50.0 2000)))
  (:reset-arm (arm &key (wait t) (reset-pose :reset-manip-pose))
    (send self :reset-arm-org arm :wait wait :reset-pose reset-pose))
  (:reset-torso (&key (wait t) (reset-pose :reset-manip-pose))
    (send self :reset-torso-org :wait wait :reset-pose reset-pose)))


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
      (ros::ros-info "switch joy from vr device to ps3joy")
      (send *ti* :switch-joy-to-ps3joy)))
  (reset))


(unix:signal 2 'signal-hook)
(unix:signal 9 'signal-hook)
(unix:signal 15 'signal-hook)


(provide :pr2-vr-interface)
