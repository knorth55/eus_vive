;; -*- mode: lisp;-*-

(ros::load-ros-manifest "actionlib_msgs")
(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "topic_tools")


(defclass robot-vive-interface
  :super propertied-object
  :slots (robot
          robot-interface
          tfl
          hmd-frame-id
          bvive-frame-id
          cvive-frame-id
          base-frame-id
          feedback-topic-name
          gripper-status-topic-name
          collision-status-topic-name
          collision-status-topic-type
          larm-grasp
          larm-grasping-p
          larm-trigger
          larm-prev-trigger
          larm-menu
          larm-prev-menu
          larm-trackpad
          larm-prev-trackpad
          larm-grip
          larm-prev-grip
          larm-enable
          larm-vive-frame-id
          larm-grasp-timeout-p
          larm-grasp-start-time
          larm-collision-p
          larm-coords-visualize-topic-name
          rarm-grasp
          rarm-grasping-p
          rarm-trigger
          rarm-prev-trigger
          rarm-menu
          rarm-prev-menu
          rarm-trackpad
          rarm-prev-trackpad
          rarm-grip
          rarm-prev-grip
          rarm-enable
          rarm-vive-frame-id
          rarm-grasp-timeout-p
          rarm-grasp-start-time
          rarm-collision-p
          rarm-coords-visualize-topic-name
          ik-stop-step
          scale
          av-tm
          av-scale
          min-time
          torso-av-tm
          torso-av-scale
          torso-min-time
          grasp-timeout-time
          rate
          arm-length
          head->shoulder-x-distance
          head->shoulder-z-distance
          bvive->shoulder-x
          bvive->shoulder-z
          ))


(defmethod robot-vive-interface
  (:init ()
    (send self :set-val 'bvive->shoulder-x nil)
    (send self :set-val 'bvive->shoulder-z nil)
    (dolist (arm (list :larm :rarm))
      (send self :set-arm-val arm :grasp nil)
      (send self :set-arm-val arm :grasping-p nil)
      (send self :set-arm-val arm :trigger nil)
      (send self :set-arm-val arm :prev-trigger nil)
      (send self :set-arm-val arm :menu nil)
      (send self :set-arm-val arm :prev-menu nil)
      (send self :set-arm-val arm :trackpad nil)
      (send self :set-arm-val arm :prev-trackpad nil)
      (send self :set-arm-val arm :grip nil)
      (send self :set-arm-val arm :prev-grip nil)
      (send self :set-arm-val arm :enable nil)
      (send self :set-arm-val arm :collision-p nil)
      (ros::subscribe (format nil "/vive~A/joy" (send self :get-arm-val arm :vive-frame-id))
                      sensor_msgs::Joy #'send self :vive-button-cb arm)
      (ros::subscribe (eval gripper-status-topic-name)
                      actionlib_msgs::GoalStatusArray #'send self :gripper-status-cb arm)
      (when (and collision-status-topic-name collision-status-topic-type)
        (ros::subscribe (eval collision-status-topic-name) collision-status-topic-type
                        #'send self :collision-status-cb arm))
      (send self :set-arm-val arm :coords-visualize-topic-name
            (format nil "/eus_vive/~A/target_pose_stamped" (if (eq arm :larm) "left" "right"))))
    (send self :set-val 'tfl (instance ros::transform-listener :init))
    (ros::advertise feedback-topic-name sensor_msgs::JoyFeedback 1)
    (ros::advertise larm-coords-visualize-topic-name geometry_msgs::PoseStamped 1)
    (ros::advertise rarm-coords-visualize-topic-name geometry_msgs::PoseStamped 1))
  (:get-arm-val (arm name)
    (send self :get-val (intern (format nil "~A-~A" (string-upcase arm) (string-upcase name)))))
  (:set-arm-val (arm name val)
    (send self :set-val (intern (format nil "~A-~A" (string-upcase arm) (string-upcase name))) val))
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
  (:arm-cb (arm &key (head t) (torso t) (mirror nil))
    (if (eq arm :arms)
      (let* ((larm-target-coords
               (send self :get-target-coords :larm :head head :mirror mirror))
             (rarm-target-coords
               (send self :get-target-coords :rarm :head head :mirror mirror))
             (target-coords (list larm-target-coords rarm-target-coords)))
        (cond
          ((and larm-target-coords rarm-target-coords)
           (send self :inverse-kinematics :arms target-coords :use-torso torso)
           (send self :angle-vector (send robot :angle-vector)
                 av-tm (send self :get-arm-controller :larm) 0 :min-time min-time :scale av-scale)
           (send self :angle-vector (send robot :angle-vector)
                 av-tm (send self :get-arm-controller :rarm) 0 :min-time min-time :scale av-scale)
           (when torso
             (send self :angle-vector (send robot :angle-vector)
                   torso-av-tm :torso-controller 0 :min-time torso-min-time :scale torso-av-scale)))
          ((and larm-target-coords (not rarm-target-coords))
           (send self :inverse-kinematics :larm larm-target-coords :use-torso torso)
           (send self :angle-vector (send robot :angle-vector)
                 av-tm (send self :get-arm-controller :larm) 0 :min-time min-time :scale av-scale)
           (when torso
             (send self :angle-vector (send robot :angle-vector)
                   torso-av-tm :torso-controller 0 :min-time torso-min-time :scale torso-av-scale)))
          ((and (not larm-target-coords) rarm-target-coords)
           (send self :inverse-kinematics :rarm rarm-target-coords :use-torso torso)
           (send self :angle-vector (send robot :angle-vector)
                 av-tm (send self :get-arm-controller :rarm) 0 :min-time min-time :scale av-scale)
           (when torso
             (send self :angle-vector (send robot :angle-vector)
                   torso-av-tm :torso-controller 0 :min-time torso-min-time :scale torso-av-scale))))
        target-coords)
      (let ((target-coords
              (send self :get-target-coords arm :head head :mirror mirror)))
        (when target-coords
          (send self :inverse-kinematics arm target-coords :use-torso torso)
          (send self :angle-vector (send robot :angle-vector)
                av-tm (send self :get-arm-controller arm)
                0 :min-time min-time :scale av-scale)
          (when torso
            (send self :angle-vector (send robot :angle-vector)
                  torso-av-tm :torso-controller 0 :min-time torso-min-time :scale torso-av-scale)))
        target-coords)))
  (:get-target-coords (arm &key (head t) (mirror nil))
    (let* ((head-coords (send (send robot :head-end-coords) :copy-worldcoords))
           (robot-height (elt (send head-coords :worldpos) 2))
          target-pos target-rot target-coords)
      (if head
        (let ((hmd->vive-coords
                (send self :get-hmd->vive-coords
                      (if mirror (send self :get-opposite-arm arm) arm)))
               vive-coords)
          (when hmd->vive-coords
            (setq vive-coords (send head-coords :transform hmd->vive-coords))
            (setq target-pos (send vive-coords :worldpos))
            (setq target-rot (send vive-coords :worldrot))))
        (let ((bvive->vive-coords
                (send self :get-bvive->vive-coords
                      (if mirror (send self :get-opposite-arm arm) arm) :wait-trigger nil))
              bvive->vive-pos)
          (when bvive->vive-coords
            (send bvive->vive-coords
                  :transform (make-coords :rpy (float-vector pi/2 0 pi/2)) :world)
            (send bvive->vive-coords :transform (make-coords :rpy (float-vector 0 pi/2 0)))
            (send bvive->vive-coords :transform (make-coords :rpy (float-vector 0 0 -pi/2)))
            (setq bvive->vive-pos (send bvive->vive-coords :worldpos))
            (setq target-pos
                  (float-vector (- (elt bvive->vive-pos 0) bvive->shoulder-x)
                                (elt bvive->vive-pos 1)
                                (- (+ robot-height (elt bvive->vive-pos 2))
                                   (+ bvive->shoulder-z head->shoulder-z-distance))))
            (setq target-rot (send bvive->vive-coords :worldrot)))))
      (when (and target-pos target-rot)
        (when mirror
          (let* ((mirror-coords (make-coords :rot target-rot))
                 (rpy-angle (car (send mirror-coords :rpy-angle))))
            (setf (elt rpy-angle 0) (* -1.0 (elt rpy-angle 0)))
            (setf (elt rpy-angle 2) (* -1.0 (elt rpy-angle 2)))
            (setq mirror-coords (make-coords :rpy rpy-angle))
            (setq target-rot (send mirror-coords :worldrot))
            (setf (elt target-pos 1) (* -1.0 (elt target-pos 1)))))
        (setq target-coords
              (make-coords :pos (float-vector
                                  (+ head->shoulder-x-distance (* scale (elt target-pos 0)))
                                  (* scale (elt target-pos 1))
                                  (- robot-height (* scale (- robot-height (elt target-pos 2)))))
                           :rot target-rot)))
      target-coords))
  (:get-hmd->vive-coords (arm)
    (when (not (or (eq arm :larm) (eq arm :rarm)))
      (ros::ros-error (format nil "~A arm is not supported ~%" arm))
      (return-from :get-hmd->vive-coords nil))
    (let ((vive-frame-id (send self :get-arm-val arm :vive-frame-id))
          coords)
      (send tfl :wait-for-transform hmd-frame-id vive-frame-id (ros::time 0) 0.1)
      (setq coords (send tfl :lookup-transform hmd-frame-id vive-frame-id (ros::time 0)))
      (when coords
        (send coords :transform (make-coords :rpy (float-vector 0 0 pi)) :world)
        (send coords :transform (make-coords :rpy (float-vector -pi/2 0 0)) :world)
        (send coords :transform (make-coords :rpy (float-vector 0 0 -pi/2)))
        (send coords :transform (make-coords :rpy (float-vector pi/2 0 0)))
        coords)))
  (:calib-vive (arm)
    (let (first-coords second-coords)
      (ros::rate rate)
      (ros::ros-info "Calibration start: ~A~%" (string-downcase arm))
      (ros::ros-info "Stretch your ~A arm and press trigger.~%" (string-downcase arm))
      (setq first-coords (send self :get-bvive->vive-coords arm :wait-trigger t))
      (ros::ros-info "Fold your ~A arm and press trigger.~%" (string-downcase arm))
      (setq second-coords (send self :get-bvive->vive-coords arm :wait-trigger t))
      (if (and (and first-coords second-coords)
               (> (elt (send first-coords :worldpos) 2)
                  (elt (send second-coords :worldpos) 2)))
        (progn
          (send self :set-val 'scale
                (/ (send self :get-val 'arm-length)
                   (norm (v- (send second-coords :worldpos) (send first-coords :worldpos)))))
          (ros::ros-info "Calibrate scale: ~A~%" (send self :get-val 'scale))
          (send self :set-val 'bvive->shoulder-x
                (- (elt (send second-coords :worldpos) 2) head->shoulder-x-distance))
          (send self :set-val 'bvive->shoulder-z (elt (send second-coords :worldpos) 1))
          (ros::ros-info "Calibration end: ~A~%" (string-downcase arm))
          (ros::ros-info "first coords:")
          (print (send first-coords :worldpos))
          (ros::ros-info "second coords:")
          (print (send second-coords :worldpos))
          (send self :send-joy-feedback arm)
          t)
        (progn
          (ros::ros-error "Calibration is failed.~%")
          (ros::ros-error "first coords:")
          (print (send first-coords :worldpos))
          (ros::ros-error "second coords:")
          (print (send second-coords :worldpos))
          (send self :send-joy-feedback arm)
          (ros::duration-sleep 1)
          (send self :send-joy-feedback arm)
          nil))))
  (:get-bvive->vive-coords (arm &key (wait-trigger nil) (wait-time 0.1))
    (let ((vive-frame-id (send self :get-arm-val arm :vive-frame-id))
          (start-time (ros::time 0))
          coords vive-trigger-p)
      (when wait-trigger
        (ros::ros-info "Waiting for trigger: ~A~%" (string-downcase arm))
        (while (and (ros::ok) (not vive-trigger-p))
          (setq vive-trigger-p (send self :vive-trigger-p arm))
          (ros::spin-once)
          (ros::sleep)))
      (send *tfl* :wait-for-transform bvive-frame-id vive-frame-id start-time wait-time)
      (setq coords (send *tfl* :lookup-transform bvive-frame-id vive-frame-id start-time))
      coords))
  (:head-cb ()
    (let (coords rpy)
      (send *tfl* :wait-for-transform bvive-frame-id hmd-frame-id (ros::time 0) 0.1)
      (setq coords (send *tfl* :lookup-transform bvive-frame-id hmd-frame-id (ros::time 0)))
      (when coords
        (send coords :transform (make-coords :rpy (float-vector 0 pi 0)) :world)
        (setq rpy
              (if (> pi/2 (abs (elt (car (send coords :rpy-angle)) 0)))
                (car (send coords :rpy-angle))
                (cadr (send coords :rpy-angle))))
        (send robot :head-neck-p :joint-angle (rad2deg (* -1 (elt rpy 2))))
        (send robot :head-neck-y :joint-angle (rad2deg (elt rpy 1)))
        (send self :angle-vector (send robot :angle-vector) av-tm
              :head-controller 0 :min-time min-time :scale av-scale))))
  (:gripper-cb (arm &key (mirror nil))
    (let ((vive-trigger-p
            (send self :vive-trigger-p (if mirror (send self :get-opposite-arm arm) arm)))
          (grasp-p (send self :get-arm-val arm :grasp)))
      (when vive-trigger-p
        (if grasp-p
          (send robot-interface :stop-grasp arm :wait nil)
          (send robot-interface :start-grasp arm :wait nil))
        (send self :set-arm-val arm :grasp (not grasp-p)))))
  (:gripper-status-cb (arm msg)
    (let ((grasping-p (some #'(lambda (x) (eq x 1)) (send-all (send msg :status_list) :status)))
          (prev-grasping-p (send self :get-arm-val arm :grasping-p))
          (grasp-start-time (send self :get-arm-val arm :grasp-start-time))
          (grasp-timeout-p nil))
      (when (and grasping-p (not prev-grasping-p))
        (send robot-interface :cancel-angle-vector
              :controller-type (send self :get-arm-controller arm)))
      (when (and grasp-start-time (not grasping-p)) (setq grasp-start-time nil))
      (when (and grasping-p grasp-timeout-time)
         (unless grasp-start-time (setq grasp-start-time (ros::time-now)))
         (setq grasp-timeout-p
               (> (- (send (ros::time-now) :to-nsec) (send grasp-start-time :to-nsec))
                  (* grasp-timeout-time 1e9))))
      (when (and grasping-p grasp-timeout-p)
        (ros::ros-error "grasp timeout for ~A seconds: ~A" grasp-timeout-time arm))
      (send self :set-arm-val arm :grasping-p grasping-p)
      (send self :set-arm-val arm :grasp-start-time grasp-start-time)
      (send self :set-arm-val arm :grasp-timeout-p grasp-timeout-p)))
  (:collision-status-cb (arm msg)
    (let ((collision-p (send msg :collision_state)))
      (when collision-p
        (send self :send-joy-feedback arm)
        (ros::ros-error "arm ~A collision detected, stopped" arm))
      (send self :set-arm-val arm :collision-p collision-p)))
  (:vive-button-cb (arm msg)
    (send self :set-arm-val arm :prev-trigger (send self :get-arm-val arm :trigger))
    (send self :set-arm-val arm :prev-menu (send self :get-arm-val arm :menu))
    (send self :set-arm-val arm :prev-trackpad (send self :get-arm-val arm :trackpad))
    (send self :set-arm-val arm :prev-grip (send self :get-arm-val arm :grip))
    (send self :set-arm-val arm :trigger (> (elt (send msg :buttons) 1) 0))
    (send self :set-arm-val arm :menu (> (elt (send msg :buttons) 0) 0))
    (send self :set-arm-val arm :trackpad (> (elt (send msg :buttons) 2) 0))
    (send self :set-arm-val arm :grip (> (elt (send msg :buttons) 3) 0)))
  (:vive-button-p (arm button)
    (cond
      ((eq button :trigger) (send self :vive-trigger-p arm))
      ((eq button :menu) (send self :vive-menu-p arm))
      ((eq button :trackpad) (send self :vive-trackpad-p arm))
      ((eq button :grip) (send self :vive-grip-p arm))
      (t nil)))
  (:vive-trigger-p (arm)
    (let ((trigger (send self :get-arm-val arm :trigger))
          (prev-trigger (send self :get-arm-val arm :prev-trigger)))
      (and (not (eq trigger prev-trigger)) trigger)))
  (:vive-menu-p (arm)
    (let ((menu (send self :get-arm-val arm :menu))
          (prev-menu (send self :get-arm-val arm :prev-menu)))
      (and (not (eq menu prev-menu)) menu)))
  (:vive-trackpad-p (arm)
    (let ((trackpad (send self :get-arm-val arm :trackpad))
          (prev-trackpad (send self :get-arm-val arm :prev-trackpad)))
      (and (not (eq trackpad prev-trackpad)) trackpad)))
  (:vive-grip-p (arm)
    (let ((grip (send self :get-arm-val arm :grip))
          (prev-grip (send self :get-arm-val arm :prev-grip)))
      (and (not (eq grip prev-grip)) grip)))
  (:send-joy-feedback (&optional (arm :larm))
    (let (msg (id (if (eq arm :larm) 2 1)))
      (setq msg (instance sensor_msgs::JoyFeedback :init
                          :type 1 :id id :intensity 3000))
      (ros::publish feedback-topic-name msg)))
  (:coords->pose-stamped (coords)
    (let ((msg (instance geometry_msgs::PoseStamped :init))
          (quat (matrix2quaternion (send coords :worldrot)))
          (pos (send coords :worldpos)))
      (send msg :header :frame_id base-frame-id)
      (send msg :pose :position :x (/ (elt pos 0) 1000.0))
      (send msg :pose :position :y (/ (elt pos 1) 1000.0))
      (send msg :pose :position :z (/ (elt pos 2) 1000.0))
      (send msg :pose :orientation :w (elt quat 0))
      (send msg :pose :orientation :x (elt quat 1))
      (send msg :pose :orientation :y (elt quat 2))
      (send msg :pose :orientation :z (elt quat 3))
      msg))
  (:visualize (arm-coords)
    (let (larm-coords rarm-coords)
      (setq larm-coords (car arm-coords))
      (when larm-coords
        (ros::publish larm-coords-visualize-topic-name
                      (send self :coords->pose-stamped larm-coords))
        (send larm-coords :draw-on :flush t :size 50 :width 5 :color #f(0 1 0)))
      (setq rarm-coords (cadr arm-coords))
      (when rarm-coords
        (ros::publish rarm-coords-visualize-topic-name
                      (send self :coords->pose-stamped rarm-coords))
        (send rarm-coords :draw-on :flush t :size 50 :width 5 :color #f(1 0 0)))
      (send *irtviewer* :draw-objects)
      (x::window-main-one)))
  (:enable-cb (&key (mirror nil) (button :menu))
    (send self :enable-arm :larm :mirror mirror :button button)
    (send self :enable-arm :rarm :mirror mirror :button button))
  (:enable-arm (arm &key (mirror nil) (button :menu))
    (let ((enable-button-p
            (send self :vive-button-p
                  (if mirror (send self :get-opposite-arm arm) arm) button))
          (enable-p (send self :get-arm-val arm :enable)))
      (when enable-button-p
        (if enable-p
          (send robot-interface :cancel-angle-vector
                :controller-type (send self :get-arm-controller arm))
          (send robot :angle-vector (send robot-interface :state :potentio-vector)))
        (send self :set-arm-val arm :enable (not enable-p))
        (send self :send-joy-feedback arm))))
  (:grasping-p (arm)
     (and (send self :get-arm-val arm :grasping-p)
          (not (send self :get-arm-val arm :grasp-timeout-p))))
  (:arm-motion-cb (&key (head t) (torso t) (mirror nil))
    (let ((arm-coords (list nil nil)))
      (if (and torso (not (or (send self grasping-p :larm) (send self grasping-p :rarm))))
        (cond
          ((and larm-enable rarm-enable)
           (send self :gripper-cb :larm :mirror mirror)
           (send self :gripper-cb :rarm :mirror mirror)
           (setq arm-coords
                 (send self :arm-cb :arms :head head :torso torso :mirror mirror)))
          ((and larm-enable (not rarm-enable))
           (send self :gripper-cb :larm :mirror mirror)
           (setf (elt arm-coords 0)
                 (send self :arm-cb :larm :head head :torso torso :mirror mirror)))
          ((and (not larm-enable) rarm-enable)
           (send self :gripper-cb :rarm :mirror mirror)
           (setf (elt arm-coords 1)
                 (send self :arm-cb :rarm :head head :torso torso :mirror mirror)))
          (t nil))
        (progn
          (when (and larm-enable (not (send self :grasping-p :larm)))
            (send self :gripper-cb :larm :mirror mirror)
            (setf (elt arm-coords 0)
                  (send self :arm-cb :larm :head head :torso nil :mirror mirror)))
          (when (and rarm-enable (not (send self :grasping-p :rarm)))
            (send self :gripper-cb :rarm :mirror mirror)
            (setf (elt arm-coords 1)
                  (send self :arm-cb :rarm :head head :torso nil :mirror mirror)))))
      arm-coords))
  (:motion-cb (&key (head t) (torso t) (mirror nil))
    (let (arm-coords)
      (cond
        ((or larm-enable rarm-enable)
         (setq arm-coords
               (send self :arm-motion-cb :head head :torso torso :mirror mirror)))
        (t nil))
      arm-coords))
  (:main-loop-step (&key (head t) (torso t) (mirror nil) (enable-button :menu) (visualize t))
    (let (arm-coords)
      (send self :enable-cb :mirror mirror :button enable-button)
      (setq arm-coords (send self :motion-cb :head head :torso torso :mirror mirror))
      (when head (send self :head-cb))
      (when visualize (send self :visualize arm-coords))))
  (:main-loop (&rest args)
    (ros::rate rate)
    (while (ros::ok)
      (send* self :main-loop-step args)
      (ros::spin-once)
      (ros::sleep))))


(defclass robot-move-base-vive-interface
  :super robot-vive-interface
  :slots (base-enable
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
          ))


(defmethod robot-move-base-vive-interface
  (:init ()
    (send-super :init)
    (send self :set-val 'vx 0.0)
    (send self :set-val 'vy 0.0)
    (send self :set-val 'vw 0.0)
    (send self :set-val 'base-enable nil)
    (ros::advertise joy-other-topic-name sensor_msgs::Joy 1))
  (:base-cb (&key (unsafe t) (mirror nil))
    (let (msg (axes (make-list 29 :initial-element 0))
              (buttons (make-list 17 :initial-element 0)))
      (cond
        ((not (or larm-trigger rarm-trigger))
         (setf (elt buttons 10) 1)
         (setf (elt buttons 12)
               (if (and larm-trackpad (not rarm-trackpad)) 1 0))
         (setf (elt buttons 14)
               (if (and (not larm-trackpad) rarm-trackpad) 1 0)))
        ((and rarm-trigger
              (or (> (abs vx) vx-thresh) (> (abs vy) vy-thresh) (> (abs vw) vw-thresh)))
         ;; for unsafe teleop
         (when (and unsafe larm-trigger) (setf (elt buttons 9) 1))
         (setf (elt buttons 10) 1)
         (setf (elt axes 3)
               (* (if mirror -1.0 1.0)
                  (* vx-scale (if (> (abs vx) vx-thresh) vx 0.0))))
         (setf (elt axes 2)
               (* (if mirror -1.0 1.0)
                  (* vy-scale (if (> (abs vy) vy-thresh) vy 0.0))))
         (setf (elt axes 0)
               (* (if mirror -1.0 1.0)
                  (* vw-scale (if (> (abs vw) vw-thresh) vw 0.0)))))
        (t nil))
      (setq msg (instance sensor_msgs::Joy :init))
      (send msg :header :stamp (ros::time-now))
      (send msg :axes axes)
      (send msg :buttons buttons)
      (ros::publish joy-other-topic-name msg)))
  (:vive-button-cb (arm msg)
    (send-super :vive-button-cb arm msg)
    (cond
      ((eq arm :larm)
       (send self :set-val 'vw
             (if (send self :get-arm-val arm :trackpad)
               (* -1 (elt (send msg :axes) 0)) 0)))
      ((eq arm :rarm)
       (send self :set-val 'vx
             (if (send self :get-arm-val arm :trackpad)
               (elt (send msg :axes) 1) 0))
       (send self :set-val 'vy
             (if (send self :get-arm-val arm :trackpad)
               (* -1 (elt (send msg :axes) 0)) 0)))
      (t nil)))
  (:switch-joy (joy-topic-name)
    (let ((joy-mux-service-name "/multiple_joystick_mux/select")
          mux-req)
      (setq mux-req (instance topic_tools::MuxSelectRequest :init))
      (send mux-req :topic joy-topic-name)
      (ros::service-call joy-mux-service-name mux-req)))
  (:switch-joy-to-vive ()
    (send self :switch-joy joy-other-topic-name))
  (:switch-joy-to-ps3joy ()
    (send self :switch-joy joy-org-topic-name))
  (:enable-cb (&key (mirror nil) (base t) (button :menu))
    (send-super :enable-cb :mirror mirror :button button)
    (when base (send self :enable-base)))
  (:enable-base ()
    (cond
      ((and (not larm-enable) (not rarm-enable))
       (unless base-enable (send self :switch-joy-to-vive))
       (send self :set-val 'base-enable t))
      ((or larm-enable rarm-enable)
       (when base-enable (send self :switch-joy-to-ps3joy))
       (send self :set-val 'base-enable nil))
      (t nil)))
  (:motion-cb (&key (head t) (torso t) (base t) (unsafe t) (mirror nil))
    (let (arm-coords)
      (cond
        ((or larm-enable rarm-enable)
         (setq arm-coords
               (send self :arm-motion-cb :head head :torso torso :mirror mirror)))
        (base-enable (when base (send self :base-cb :unsafe unsafe :mirror mirror)))
        (t nil))
      arm-coords))
  (:main-loop-step (&key (head t) (torso t) (base t) (unsafe t) (mirror nil) (enable-button :menu) (visualize t))
    (let (arm-coords)
      (send self :enable-cb :mirror mirror :base base :button enable-button)
      (setq arm-coords
            (send self :motion-cb :head head :torso torso
                  :base base :unsafe unsafe :mirror mirror))
      (when head (send self :head-cb))
      (when visualize (send self :visualize arm-coords)))))

(provide :robot-vive-interface)
