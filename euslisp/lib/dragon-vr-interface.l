;; -*- mode: lisp;-*-
(load "package://dragon/euslisp/quad/dragon-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(if (not (assoc :init-org (send robot-vr-interface :methods)))
  (rplaca (assoc :init (send robot-vr-interface :methods)) :init-org))
(if (not (assoc :reset-org (send robot-vr-interface :methods)))
  (rplaca (assoc :reset (send robot-vr-interface :methods)) :reset-org))
(if (not (assoc :reset-arm-org (send robot-vr-interface :methods)))
  (rplaca (assoc :reset-arm (send robot-vr-interface :methods)) :reset-arm-org))
(if (not (assoc :disable-org (send robot-vr-interface :methods)))
  (rplaca (assoc :disable (send robot-vr-interface :methods)) :disable-org))
(if (not (assoc :enable-org (send robot-vr-interface :methods)))
  (rplaca (assoc :enable (send robot-vr-interface :methods)) :enable-org))


(defmethod robot-vr-interface
  (:init (&rest args)
    (send self :set-val 'robot *dragon*)
    (send self :set-val 'robot-interface *ri*)
    (send self :set-val 'camera-model *camera-model*)
    (send self :set-val 'rate 10)
    (send self :set-val 'end-coords-pos-diff-thresh 400)
    (send self :set-val 'draw-object-list (list *dragon* *background-cube*))
    ;; for dragon
    (send self :set-val 'base-frame-id "root")
    (send self :set-val 'head-frame-id "head")
    (send self :set-val 'ik-stop-step 10)
    (send self :set-val 'scale 1.5)
    (send self :set-val 'av-tm 300)
    (send self :set-val 'av-scale 5.0)
    (send self :set-val 'min-time 0.3)
    (send self :set-val 'grasp-timeout-time nil)
    (send self :set-val 'arm-length 1800)
    (send self :set-val 'head->shoulder-x-distance 100)
    (send self :set-val 'head->shoulder-z-distance 50)
    (send self :set-arm-val :larm :gripper-status-topic-name
          "/dragon/l_gripper_controller/status")
    (send self :set-arm-val :rarm :gripper-status-topic-name
          "/dragon/r_gripper_controller/status")
    (send* self :init-org args))
  (:reset (&key (loop-enable t))
    (send self :reset-org :loop-enable loop-enable :torso nil))
  (:reset-arm (arm &key (wait t))
    (send self :reset-arm-org arm :wait wait :reset-pose :reset-manip-pose))
  (:enable () (send self :enable-org :torso nil))
  (:disable () (send self :disable-org :torso nil))
  (:inverse-kinematics (arm target-coords &rest args)
    (if (eq arm :arms)
      ;; only for larm
      (send* robot :inverse-kinematics (car target-coords) :rotation-axis t
             :move-target (send robot :larm :end-coords)
             :avoid-collision-distance 5 :revert-if-fail nil :stop ik-stop-step
             :debug-view nil args)
      (send* robot :inverse-kinematics target-coords
             :rotation-axis t :move-target (send robot :larm :end-coords)
             :avoid-collision-distance 5 :revert-if-fail nil :stop ik-stop-step
             :debug-view nil args)))
  (:start () (send robot-interface :start))
  (:takeoff () (send robot-interface :takeoff)))


(defun signal-hook (sig code)
  (if (boundp '*ri*)
    (progn
      (ros::ros-info "cancel larm controller")
      (send *ri* :cancel-angle-vector :controller-type :larm-controller)))
  (reset))


(unix:signal 2 'signal-hook)
(unix:signal 9 'signal-hook)
(unix:signal 15 'signal-hook)


(provide :dragon-vr-interface)
