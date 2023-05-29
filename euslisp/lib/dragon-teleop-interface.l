;; -*- mode: lisp;-*-

(load "package://dragon/euslisp/quad/dragon-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")


(if (not (assoc :init-dragon-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :init (send robot-teleop-interface :methods)) :init-dragon-org))
(if (not (assoc :reset-dragon-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :reset (send robot-teleop-interface :methods)) :reset-dragon-org))
(if (not (assoc :reset-arm-dragon-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :reset-arm (send robot-teleop-interface :methods)) :reset-arm-dragon-org))
(if (not (assoc :disable-dragon-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :disable (send robot-teleop-interface :methods)) :disable-dragon-org))
(if (not (assoc :enable-dragon-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :enable (send robot-teleop-interface :methods)) :enable-dragon-org))


(defmethod robot-teleop-interface
  (:init (&rest args)
    (prog1
      (send* self :init-dragon-org args)
      (send self :set-val 'robot *dragon*)
      (send self :set-val 'robot-interface *ri*)
      (send self :set-val 'camera-model *camera-model*)
      (send self :set-val 'rate 10)
      (send self :set-val 'end-coords-pos-diff-thresh 400)
      (send self :set-val 'draw-object-list (list *dragon* *background-cube*))
      ;; dragon frame
      (send self :set-val 'base-frame-id "root")
      (send self :set-val 'head-frame-id "head")
      ;; dragon ik
      (send self :set-val 'arm-cb-solve-ik t)
      (send self :set-val 'ik-stop-step 10)
      (send self :set-val 'av-tm 300)
      (send self :set-val 'av-scale 5.0)
      (send self :set-val 'min-time 0.3)
      ;; dragon gripper
      (send self :set-val 'grasp-timeout-time nil)
      ;; dragon hardware configuration
      (send self :set-val 'scale 1.5)
      (send self :set-val 'arm-length 1800)
      (send self :set-val 'head->shoulder-x-distance 100)
      (send self :set-val 'head->shoulder-z-distance 50)

      (send self :set-arm-val :larm :gripper-status-topic-name
            "/dragon/l_gripper_controller/status")
      (send self :set-arm-val :rarm :gripper-status-topic-name
            "/dragon/r_gripper_controller/status")))
  (:reset (&key (loop-enable t))
    (send self :reset-dragon-org :loop-enable loop-enable :torso nil))
  (:reset-arm (arm &key (wait t))
    (send self :reset-arm-dragon-org arm :wait wait :reset-pose :reset-manip-pose))
  (:enable () (send self :enable-dragon-org :torso nil))
  (:disable () (send self :disable-dragon-org :torso nil))
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


(defun make-dragon-irtviewer (&key (no-window t))
  (if (and no-window
           (string>= (car lisp-implementation-version) "9.28"))
    (make-irtviewer-no-window))
  (objects (list *dragon*))
  (send *irtviewer* :change-background (float-vector 1 1 1))
  (send *irtviewer* :draw-floor 100)
  (send *irtviewer* :floor-color #f(0 0 0))
  (setq *background-cube* (make-cube 10 6000 6000))
  (send *background-cube* :set-color #f(1 1 1))
  (send *background-cube* :translate #f(-1000 0 0)))


(defun make-dragon-camera-model (&key (no-window t))
  (setq *camera-model*
        (if (string>= (car lisp-implementation-version) "9.28")
          (make-camera-from-param
            :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t :no-window no-window)
          (make-camera-from-param
            :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t)))
  (send *camera-model* :translate #f(1500 0 0))
  (send *camera-model* :rotate -pi/2 :y :world)
  (send *camera-model* :rotate -pi/2 :x :world))


(defun signal-hook (sig code)
  (if (boundp '*ri*)
    (progn
      (ros::ros-info "cancel larm controller")
      (send *ri* :cancel-angle-vector :controller-type :larm-controller)))
  (reset))


(unix:signal 2 'signal-hook)
(unix:signal 9 'signal-hook)
(unix:signal 15 'signal-hook)


(provide :dragon-teleop-interface)
