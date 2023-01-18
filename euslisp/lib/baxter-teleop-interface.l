;; -*- mode: lisp;-*-
(ros::load-ros-manifest "baxter_core_msgs")

(require :baxter-interface "package://eus_teleop/euslisp/lib/baxter-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")


(if (not (assoc :init-baxter-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :init (send robot-teleop-interface :methods)) :init-baxter-org))
(if (not (assoc :reset-baxter-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :reset (send robot-teleop-interface :methods)) :reset-baxter-org))
(if (not (assoc :reset-arm-baxter-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :reset-arm (send robot-teleop-interface :methods)) :reset-arm-baxter-org))
(if (not (assoc :disable-baxter-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :disable (send robot-teleop-interface :methods)) :disable-baxter-org))
(if (not (assoc :enable-baxter-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :enable (send robot-teleop-interface :methods)) :enable-baxter-org))
(if (not (assoc :arm-motion-cb-baxter-org (send robot-teleop-interface :methods)))
  (rplaca (assoc :arm-motion-cb (send robot-teleop-interface :methods)) :arm-motion-cb-baxter-org))


(defmethod robot-teleop-interface
  (:init (&rest args)
    (prog1
      (send* self :init-baxter-org args)
      (send self :set-val 'robot *baxter*)
      (send self :set-val 'robot-interface *ri*)
      (send self :set-val 'camera-model *camera-model*)
      (send self :set-val 'rate 10)
      (send self :set-val 'end-coords-pos-diff-thresh 400)
      (send self :set-val 'draw-object-list (list *baxter* *background-cube*))
      ;; baxter frame
      (send self :set-val 'base-frame-id "base")
      (send self :set-val 'head-frame-id "head")
      ;; baxter ik
      (send self :set-val 'arm-cb-solve-ik t)
      (send self :set-val 'ik-stop-step 10)
      (send self :set-val 'av-tm 300)
      (send self :set-val 'av-scale 3.0)
      (send self :set-val 'min-time 0.3)
      ;; baxter gripper
      (send self :set-val 'grasp-timeout-time 1.5)
      ;; baxter hardware configuration
      (send self :set-val 'arm-length 1000)
      (send self :set-val 'head->shoulder-x-distance 100)
      (send self :set-val 'head->shoulder-z-distance 50)

      (send self :set-arm-val :larm :gripper-status-topic-name
            "/robot/end_effector/left_gripper/gripper_action/status")
      (send self :set-arm-val :rarm :gripper-status-topic-name
            "/robot/end_effector/right_gripper/gripper_action/status")
      (send self :set-arm-val :larm :collision-status-topic-name
            "/robot/limb/left/collision_detection_state")
      (send self :set-arm-val :rarm :collision-status-topic-name
            "/robot/limb/right/collision_detection_state")
      (send self :set-val 'collision-status-topic-type baxter_core_msgs::CollisionDetectionState)))
  (:reset (&key (loop-enable t))
    (send self :reset-baxter-org :loop-enable loop-enable :torso nil))
  (:reset-arm (arm &key (wait t))
    (send self :reset-arm-baxter-org arm :wait wait :reset-pose :reset-teleop-pose)
    (send self :close-thumb arm))
  (:enable () (send self :enable-baxter-org :torso nil))
  (:disable () (send self :disable-baxter-org :torso nil))
  (:move-head (yaw pitch roll)
    ;; no pitch joint
    (send robot :head-neck-y :joint-angle (rad2deg yaw))
    (send self :angle-vector (send robot :angle-vector) av-tm
          :head-controller 0 :min-time min-time :scale av-scale))
  (:get-head-end-coords ()
    (let (coords)
      (send tfl :wait-for-transform base-frame-id head-frame-id (ros::time 0) 0.1)
      (setq coords (send tfl :lookup-transform base-frame-id head-frame-id (ros::time 0)))
      (if coords
        (setq coords (make-coords :pos (send coords :worldpos)
                                  :rpy (float-vector 0 pi/2 0))))
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
             :debug-view nil args)))
  (:open-thumb (arm)
    (send robot-interface :open-thumb arm))
  (:close-thumb (arm)
    (send robot-interface :close-thumb arm))
  (:start-heater (arm)
    (send robot-interface :start-heater arm))
  (:stop-heater (arm)
    (send robot-interface :stop-heater arm))
  (:thumb-rotate-cb (arm &key (mirror nil) (button :trackpad))
    (if (equal (send self :get-arm-val arm :gripper-type) :softhand-v2)
      (let ((thumb-rotate-button-p
              (if button
                (send self :controller-button-p
                      (if mirror (send self :get-opposite-arm arm) arm) button
                      :button-toggle t)))
            (thumb-open-p (send self :get-arm-val arm :thumb-open)))
        (if thumb-rotate-button-p
          (progn
            (if thumb-open-p
              (send self :close-thumb arm)
              (send self :open-thumb arm))
            (send self :set-arm-val arm :thumb-open (not thumb-open-p)))))))
  (:arm-motion-cb (&rest args &key (mirror nil) (thumb-rotate-button :trackpad) &allow-other-keys)
    (cond
      ((and larm-enable rarm-enable)
       (send self :thumb-rotate-cb :larm :mirror mirror :button thumb-rotate-button)
       (send self :thumb-rotate-cb :rarm :mirror mirror :button thumb-rotate-button))
      ((and larm-enable (not rarm-enable))
       (send self :thumb-rotate-cb :larm :mirror mirror :button thumb-rotate-button))
      ((and (not larm-enable) rarm-enable)
       (send self :thumb-rotate-cb :rarm :mirror mirror :button thumb-rotate-button))
      (t nil))
    (send* self :arm-motion-cb-baxter-org :mirror mirror args))
  (:start-grasp (arm &rest args)
   (if (equal (send self :get-arm-val arm :gripper-type) :parallel)
     (send* robot-interface :start-grasp arm :wait nil args)
     (send* robot-interface :start-grasp arm args)))
  (:stop-grasp (arm &rest args)
   (if (equal (send self :get-arm-val arm :gripper-type) :parallel)
     (send* robot-interface :stop-grasp arm :wait nil args)
     (send* robot-interface :stop-grasp arm args)))
  )


(defun make-baxter-irtviewer (&key (no-window t))
  (if (and no-window
           (string>= (car lisp-implementation-version) "9.28"))
    (make-irtviewer-no-window))
  (objects (list *baxter*))
  (send *irtviewer* :change-background (float-vector 1 1 1))
  (send *irtviewer* :draw-floor 100)
  (send *irtviewer* :floor-color #f(0 0 0))
  (setq *background-cube* (make-cube 10 6000 6000))
  (send *background-cube* :set-color #f(1 1 1))
  (send *background-cube* :translate #f(-1000 0 0)))


(defun make-baxter-camera-model (&key (no-window t))
  (setq *camera-model*
        (if (string>= (car lisp-implementation-version) "9.28")
          (make-camera-from-param
            :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t :no-window no-window)
          (make-camera-from-param
            :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t)))
  (send *camera-model* :translate #f(1500 0 600))
  (send *camera-model* :rotate -pi/2 :y :world)
  (send *camera-model* :rotate -pi/2 :x :world)
  (send *camera-model* :rotate -0.30 :y :world))


(defun signal-hook (sig code)
  (if (boundp '*ri*)
    (progn
      (ros::ros-info "cancel larm controller")
      (send *ri* :cancel-angle-vector :controller-type :larm-controller)
      (ros::ros-info "cancel rarm controller")
      (send *ri* :cancel-angle-vector :controller-type :rarm-controller)))
  (reset))


(unix:signal 2 'signal-hook)
(unix:signal 9 'signal-hook)
(unix:signal 15 'signal-hook)


(provide :baxter-teleop-interface)
