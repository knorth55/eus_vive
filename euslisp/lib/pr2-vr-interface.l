;; -*- mode: lisp;-*-

(require :pr2-interface "package://pr2eus/pr2-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-move-base-vr-interface "package://eus_vive/euslisp/lib/robot-move-base-vr-interface.l")


(if (not (assoc :init-pr2-org (send robot-vr-interface :methods)))
  (rplaca (assoc :init (send robot-vr-interface :methods)) :init-pr2-org))
(if (not (assoc :reset-arm-pr2-org (send robot-vr-interface :methods)))
  (rplaca (assoc :reset-arm (send robot-vr-interface :methods)) :reset-arm-pr2-org))
(if (not (assoc :reset-torso-pr2-org (send robot-vr-interface :methods)))
  (rplaca (assoc :reset-torso (send robot-vr-interface :methods)) :reset-torso-pr2-org))


(defmethod robot-vr-interface
  (:init (&rest args)
    (prog1
      (send* self :init-pr2-org args)
      (send self :set-val 'robot *pr2*)
      (send self :set-val 'robot-interface *ri*)
      (send self :set-val 'camera-model *camera-model*)
      (send self :set-val 'rate 10)
      (send self :set-val 'end-coords-pos-diff-thresh 400)
      (send self :set-val 'draw-object-list (list *pr2*))
      ;; pr2 frame
      (send self :set-val 'base-frame-id "base_footprint")
      (send self :set-val 'head-frame-id "head_tilt_link")
      ;; pr2 ik
      (send self :set-val 'arm-cb-solve-ik t)
      (send self :set-val 'ik-stop-step 10)
      (send self :set-val 'av-tm 300)
      (send self :set-val 'av-scale 5.0)
      (send self :set-val 'min-time 0.3)
      (send self :set-val 'torso-av-tm 500)
      (send self :set-val 'torso-av-scale 1.5)
      (send self :set-val 'torso-min-time 0.5)
      (send self :set-val 'torso-z-thresh 100)
      (send self :set-val 'torso-ik-weight 0.0001)
      ;; pr2 gripper
      (send self :set-val 'grasp-timeout-time nil)
      ;; pr2 move base
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
      ;; pr2 hardware configuration
      (send self :set-val 'scale 1.5)
      (send self :set-val 'arm-length 600)
      (send self :set-val 'head->shoulder-x-distance 100)
      (send self :set-val 'head->shoulder-z-distance 50)
  
      (send self :set-arm-val :larm :gripper-status-topic-name
            "/l_gripper_controller/gripper_action/status")
      (send self :set-arm-val :rarm :gripper-status-topic-name
            "/r_gripper_controller/gripper_action/status")))
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
    (send self :reset-arm-pr2-org arm :wait wait :reset-pose reset-pose))
  (:reset-torso (&key (wait t) (reset-pose :reset-manip-pose))
    (send self :reset-torso-pr2-org :wait wait :reset-pose reset-pose)))


(defun make-pr2-irtviewer (&key (no-window t))
  (if (and no-window
           (string>= (car lisp-implementation-version) "9.28"))
    (make-irtviewer-no-window))
  (objects (list *pr2*))
  (send *irtviewer* :change-background (float-vector 1 1 1))
  (send *irtviewer* :draw-floor 100)
  (send *irtviewer* :floor-color #f(0 0 0)))


(defun make-pr2-camera-model (&key (no-window t))
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
      (ros::ros-info "switch joy from vr device to ps3joy")
      (send *ti* :switch-joy-to-ps3joy)))
  (reset))


(unix:signal 2 'signal-hook)
(unix:signal 9 'signal-hook)
(unix:signal 15 'signal-hook)


(provide :pr2-vr-interface)
