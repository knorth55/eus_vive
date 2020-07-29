;; -*- mode: lisp;-*-

(ros::load-ros-manifest "actionlib_msgs")
(ros::load-ros-manifest "eus_vive")
(ros::load-ros-manifest "moveit_msgs")
(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "std_srvs")

(load "package://jsk_interactive_marker/euslisp/display-robot-state.l")


(defclass robot-vr-interface
  :super propertied-object
  :slots (robot
          robot-interface
          tfl
          camera-model
          base-frame-id
          head-frame-id
          gripper-status-topic-name
          collision-status-topic-name
          collision-status-topic-type
          robot-state-visualize-topic-name
          irtviewer-visualize-topic-name
          eus-vive-status-topic-name
          eus-vive-reset-service-name
          eus-vive-enable-service-name
          eus-vive-disable-service-name
          eus-vive-calib-service-name
          loop-enable
          draw-object-list
          larm-enable
          larm-grasp
          larm-grasping-p
          larm-grasp-timeout-p
          larm-grasp-start-time
          larm-collision-p
          larm-coords-visualize-topic-name
          larm-current-end-coords
          larm-track-error-p
          rarm-enable
          rarm-grasp
          rarm-grasping-p
          rarm-grasp-timeout-p
          rarm-grasp-start-time
          rarm-collision-p
          rarm-coords-visualize-topic-name
          rarm-current-end-coords
          rarm-track-error-p
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
          end-coords-pos-diff-thresh
          target-coords-max-x
          target-coords-max-y
          target-coords-max-z
          target-coords-min-x
          target-coords-min-y
          target-coords-min-z
          ))


(defmethod robot-vr-interface
  (:init (&key (loop-enable t))
    (send self :reset :loop-enable loop-enable)
    ;; for workspace
    (send self :set-val 'target-coords-max-x (ros::get-param "/eus_vive/workspace/max_x"))
    (send self :set-val 'target-coords-max-y (ros::get-param "/eus_vive/workspace/max_y"))
    (send self :set-val 'target-coords-max-z (ros::get-param "/eus_vive/workspace/max_z"))
    (send self :set-val 'target-coords-min-x (ros::get-param "/eus_vive/workspace/min_x"))
    (send self :set-val 'target-coords-min-y (ros::get-param "/eus_vive/workspace/min_y"))
    (send self :set-val 'target-coords-min-z (ros::get-param "/eus_vive/workspace/min_z"))
    ;; for eus_vive
    (send self :set-val 'robot-state-visualize-topic-name "/display_robot_state")
    (send self :set-val 'irtviewer-visualize-topic-name "/eus_vive/irtviewer/image")
    (send self :set-val 'eus-vive-status-topic-name "/eus_vive/status")
    (send self :set-val 'eus-vive-reset-service-name "/eus_vive/reset")
    (send self :set-val 'eus-vive-enable-service-name "/eus_vive/enable")
    (send self :set-val 'eus-vive-disable-service-name "/eus_vive/disable")
    (send self :set-val 'eus-vive-calib-service-name "/eus_vive/calibrate")
    (dolist (arm (list :larm :rarm))
      (ros::subscribe (eval gripper-status-topic-name)
                      actionlib_msgs::GoalStatusArray #'send self :gripper-status-cb arm)
      (when (and collision-status-topic-name collision-status-topic-type)
        (ros::subscribe (eval collision-status-topic-name) collision-status-topic-type
                        #'send self :collision-status-cb arm))
      (send self :set-arm-val arm :coords-visualize-topic-name
            (format nil "/eus_vive/~A/target_pose_stamped" (if (eq arm :larm) "left" "right"))))
    (send self :set-val 'tfl (instance ros::transform-listener :init))
    (ros::advertise larm-coords-visualize-topic-name geometry_msgs::PoseStamped 1)
    (ros::advertise rarm-coords-visualize-topic-name geometry_msgs::PoseStamped 1)
    (ros::advertise robot-state-visualize-topic-name moveit_msgs::DisplayRobotState 1)
    (ros::advertise eus-vive-status-topic-name eus_vive::EusViveStatusArray 1)
    (ros::advertise-service eus-vive-reset-service-name std_srvs::Empty
                            #'send self :reset-service)
    (ros::advertise-service eus-vive-enable-service-name std_srvs::Empty
                            #'send self :enable-service)
    (ros::advertise-service eus-vive-disable-service-name std_srvs::Empty
                            #'send self :disable-service)
    (ros::advertise-service eus-vive-calib-service-name std_srvs::Empty
                            #'send self :calib-service)
    (ros::advertise irtviewer-visualize-topic-name sensor_msgs::Image 1))
  (:reset (&key (loop-enable t))
    (send self :set-val 'loop-enable loop-enable)
    (send self :reset-arm :larm)
    (send self :reset-arm :rarm))
  (:reset-arm (arm)
    (send self :stop-grasp arm :wait nil)
    (send robot-interface :cancel-angle-vector
          :controller-type (send self :get-arm-controller arm))
    (send self :set-arm-val arm :grasp nil)
    (send self :set-arm-val arm :grasping-p nil)
    (send self :set-arm-val arm :enable nil)
    (send self :set-arm-val arm :collision-p nil)
    (send self :set-arm-val arm :current-end-coords nil)
    (send self :set-arm-val arm :track-error-p nil))
  (:enable ()
    (send self :reset :loop-enable t))
  (:disable ()
    (send self :reset :loop-enable nil))
  (:calibrate ()
    (let (calib-p)
      (setq calib-p (send *ti* :calib-controller))
      (unless calib-p (send *ri* :speak "Please try calibration again." :wait t))
      calib-p))
  (:reset-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Reset button pressed. I go back to reset pose." :wait nil)
      (send self :reset :loop-enable nil)
      res))
  (:enable-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Enable button pressed. Demo started." :wait nil)
      (send self :enable)
      res))
  (:disable-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Disable button pressed. Demo stopped." :wait nil)
      (send self :disable)
      res))
  (:calib-service (req)
    (let ((res (instance std_srvs::EmptyResponse :init)))
      (send *ri* :speak "Calibrate button pressed." :wait t)
      (send self :reset :loop-enable t)
      (send self :calibrate)
      (send self :reset :loop-enable nil)
      res))
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
  (:start-grasp (arm &key (wait t))
     (send robot-interface :start-grasp arm :wait wait))
  (:stop-grasp (arm &key (wait t))
     (send robot-interface :stop-grasp arm :wait wait))
  (:filter-unsafe-target-coords (arm target-coords)
    (unless target-coords (return-from :filter-unsafe-target-coords nil))
    (let* ((target-worldpos (send target-coords :worldpos))
           (end-coords-pos-diff
             (norm (v- target-worldpos
                       (send (send self :get-arm-val arm :current-end-coords) :worldpos))))
           (target-coords-x (elt target-worldpos 0))
           (target-coords-y (elt target-worldpos 1))
           (target-coords-z (elt target-worldpos 2)))
      (cond
        ((> end-coords-pos-diff end-coords-pos-diff-thresh)
          (send self :send-joy-feedback arm)
          (ros::ros-error "arm ~A target-coords is too far from current position: ~A > ~A"
                          arm end-coords-pos-diff end-coords-pos-diff-thresh)
          (send self :set-arm-val arm :track-error-p t)
          nil)
        ((or (and target-coords-max-x (> target-coords-x target-coords-max-x))
             (and target-coords-min-x (> target-coords-min-x target-coords-x)))
          (send self :send-joy-feedback arm)
          (ros::ros-error "arm ~A target-coords is out of workspace: ~A > ~A > ~A"
                          arm target-coords-max-x target-coords-x target-coords-min-x)
          (send self :set-arm-val arm :track-error-p t)
          nil)
        ((or (and target-coords-max-y (> target-coords-y target-coords-max-y))
             (and target-coords-min-y (> target-coords-min-y target-coords-y)))
          (send self :send-joy-feedback arm)
          (ros::ros-error "arm ~A target-coords is out of workspace: ~A > ~A > ~A"
                          arm target-coords-max-y target-coords-y target-coords-min-y)
          (send self :set-arm-val arm :track-error-p t)
          nil)
        ((or (and target-coords-max-z (> target-coords-z target-coords-max-z))
             (and target-coords-min-z (> target-coords-min-z target-coords-z)))
          (send self :send-joy-feedback arm)
          (ros::ros-error "arm ~A target-coords is out of workspace: ~A > ~A > ~A"
                          arm target-coords-max-z target-coords-z target-coords-min-z)
          (send self :set-arm-val arm :track-error-p t)
          nil)
        (t
          (send self :set-arm-val arm :track-error-p nil)
          target-coords))))
  (:arm-cb (arm &key (head t) (torso t) (safe t) (mirror nil))
    (if (eq arm :arms)
      (let* ((larm-raw-target-coords
               (send self :get-target-coords :larm :head head :mirror mirror))
             (larm-target-coords
               (if safe (send self :filter-unsafe-target-coords :larm larm-raw-target-coords)
                 larm-raw-target-coords))
             (rarm-raw-target-coords
               (send self :get-target-coords :rarm :head head :mirror mirror))
             (rarm-target-coords
               (if safe (send self :filter-unsafe-target-coords :rarm rarm-raw-target-coords)
                 rarm-raw-target-coords))
             (raw-target-coords (list larm-raw-target-coords rarm-raw-target-coords))
             (target-coords (list larm-target-coords rarm-target-coords)))
        (cond
          ((and larm-raw-target-coords rarm-raw-target-coords)
           (send self :inverse-kinematics :arms raw-target-coords :use-torso torso))
          ((and larm-raw-target-coords (not rarm-raw-target-coords))
           (send self :inverse-kinematics :larm larm-raw-target-coords :use-torso torso))
          ((and (not larm-raw-target-coords) rarm-raw-target-coords)
           (send self :inverse-kinematics :rarm rarm-raw-target-coords :use-torso torso))
          (t nil))
        (when loop-enable
          (cond
            ((and larm-target-coords rarm-target-coords)
             (send self :angle-vector (send robot :angle-vector)
                   av-tm (send self :get-arm-controller :larm) 0
                   :min-time min-time :scale av-scale)
             (send self :angle-vector (send robot :angle-vector)
                   av-tm (send self :get-arm-controller :rarm) 0
                   :min-time min-time :scale av-scale)
             (when torso
               (send self :angle-vector (send robot :angle-vector)
                     torso-av-tm :torso-controller 0
                     :min-time torso-min-time :scale torso-av-scale)))
            ((and larm-target-coords (not rarm-target-coords))
             (send self :angle-vector (send robot :angle-vector)
                   av-tm (send self :get-arm-controller :larm) 0
                   :min-time min-time :scale av-scale)
             (when torso
               (send self :angle-vector (send robot :angle-vector)
                     torso-av-tm :torso-controller 0
                     :min-time torso-min-time :scale torso-av-scale)))
            ((and (not larm-target-coords) rarm-target-coords)
             (send self :angle-vector (send robot :angle-vector)
                   av-tm (send self :get-arm-controller :rarm) 0
                   :min-time min-time :scale av-scale)
             (when torso
               (send self :angle-vector (send robot :angle-vector)
                     torso-av-tm :torso-controller 0
                     :min-time torso-min-time :scale torso-av-scale)))
            (t nil)))
        raw-target-coords)
      (let* ((raw-target-coords
               (send self :get-target-coords arm :head head :mirror mirror))
             (target-coords
               (if safe (send self :filter-unsafe-target-coords arm raw-target-coords)
                 raw-target-coords)))
        (when raw-target-coords
          (send self :inverse-kinematics arm raw-target-coords :use-torso torso))
        (when (and loop-enable target-coords)
          (send self :angle-vector (send robot :angle-vector)
                av-tm (send self :get-arm-controller arm)
                0 :min-time min-time :scale av-scale)
          (when torso
            (send self :angle-vector (send robot :angle-vector)
                  torso-av-tm :torso-controller 0 :min-time torso-min-time :scale torso-av-scale)))
        raw-target-coords)))
  (:get-head-end-coords ()
    (send (send robot :head :end-coords) :copy-worldcoords))
  (:head-cb ()
    (let ((ypr-angle (send self :get-head-ypr-angle)))
      (when ypr-angle
        (send self :move-head (elt ypr-angle 0) (elt ypr-angle 1) (elt ypr-angle 2)))))
  (:move-head (yaw pitch roll)
    (send robot :head-neck-p :joint-angle (rad2deg pitch))
    (send robot :head-neck-y :joint-angle (rad2deg yaw))
    (send self :angle-vector (send robot :angle-vector) av-tm
          :head-controller 0 :min-time min-time :scale av-scale))
  (:gripper-cb (arm &key (mirror nil) (button :trigger))
    (let ((controller-button-p
            (send self :controller-button-p
                  (if mirror (send self :get-opposite-arm arm) arm) button))
          (grasp-p (send self :get-arm-val arm :grasp)))
      (when controller-button-p
        (if grasp-p
          (send self :stop-grasp arm :wait nil)
          (send self :start-grasp arm :wait nil))
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
  (:coords->pose-stamped (coords)
    (let ((msg (instance geometry_msgs::PoseStamped :init))
          (rot (send coords :worldrot))
          (pos (send coords :worldpos)))
      (send msg :header :frame_id base-frame-id)
      (send msg :pose :position (ros::pos->tf-translation pos))
      (send msg :pose :orientation (ros::rot->tf-quaternion rot))
      msg))
  (:generate-eus-vive-status-msg ()
    (let ((eus-vive-status-msg (instance eus_vive::EusViveStatusArray :init))
          (now (ros::time-now))
          (eus-vive-status nil))
      (send eus-vive-status-msg :header :stamp now)
      (dolist (arm (list :larm :rarm))
        (let ((msg (instance eus_vive::EusViveStatus :init)))
          (send msg :header :stamp now)
          (send msg :part_name (string-downcase arm))
          (send msg :enable (send self :get-arm-val arm :enable))
          (send msg :collision (send self :get-arm-val arm :collision-p))
          (send msg :track_error (send self :get-arm-val arm :track-error-p))
          (setq eus-vive-status (append eus-vive-status (list msg)))))
      (send eus-vive-status-msg :status eus-vive-status)
      eus-vive-status-msg))
  (:visualize (arm-coords)
    (let ((camera-draw-object-list draw-object-list)
          (eus-vive-status-msg (send self :generate-eus-vive-status-msg))
          larm-cube larm-coords rarm-cube rarm-coords)
      (setq larm-coords (car arm-coords))
      (when larm-coords
        (ros::publish larm-coords-visualize-topic-name
                      (send self :coords->pose-stamped larm-coords))
        (send larm-coords :draw-on :flush t :size 50 :width 5 :color #f(0 1 0))
        (setq larm-cube (make-cube 100 100 100))
        (if (or (send self :get-arm-val :larm :collision-p)
                (send self :get-arm-val :larm :track-error-p))
          (send larm-cube :set-color :red)
          (send larm-cube :set-color :green))
        (send larm-cube :4x4 (send larm-coords :4x4))
        (setq camera-draw-object-list (append camera-draw-object-list (list larm-cube))))
      (setq rarm-coords (cadr arm-coords))
      (when rarm-coords
        (ros::publish rarm-coords-visualize-topic-name
                      (send self :coords->pose-stamped rarm-coords))
        (send rarm-coords :draw-on :flush t :size 50 :width 5 :color #f(1 0 0))
        (setq rarm-cube (make-cube 100 100 100))
        (if (or (send self :get-arm-val :rarm :collision-p)
                (send self :get-arm-val :rarm :track-error-p))
          (send rarm-cube :set-color :red)
          (send rarm-cube :set-color :blue))
        (send rarm-cube :4x4 (send rarm-coords :4x4))
        (setq camera-draw-object-list (append camera-draw-object-list (list rarm-cube))))
      (ros::publish robot-state-visualize-topic-name
                    (angle-vector-to-display-robot-state
                      robot (send (send robot :link base-frame-id) :copy-worldcoords)))
      (ros::publish eus-vive-status-topic-name eus-vive-status-msg)
      (send *irtviewer* :draw-objects)
      (send camera-model :draw-objects camera-draw-object-list)
      (ros::publish irtviewer-visualize-topic-name
                    (ros::image->sensor_msgs/Image (send camera-model :get-image)))
      (x::window-main-one)))
  (:enable-cb (&key (mirror nil) (button :menu))
    (send self :enable-arm :larm :mirror mirror :button button)
    (send self :enable-arm :rarm :mirror mirror :button button))
  (:enable-arm (arm &key (mirror nil) (button :menu))
    (let ((enable-button-p
            (send self :controller-button-p
                  (if mirror (send self :get-opposite-arm arm) arm) button))
          (enable-p (send self :get-arm-val arm :enable)))
      (when enable-button-p
        (if enable-p
          (progn
            (send robot-interface :cancel-angle-vector
                  :controller-type (send self :get-arm-controller arm))
            (send self :set-arm-val arm :track-error-p nil)
            (send self :set-arm-val arm :collision-p nil)
            (send robot-interface :speak
                  (format nil "Disable ~A arm"
                          (if mirror (if (eq arm :larm) "right" "left")
                            (if (eq arm :larm) "left" "right"))))
            (ros::ros-info "arm: ~A stopping" arm))
          (progn
            (send robot :angle-vector (send robot-interface :state :potentio-vector))
            (send robot-interface :speak
                  (format nil "Enable ~A arm"
                          (if mirror (if (eq arm :larm) "right" "left")
                            (if (eq arm :larm) "left" "right"))))
            (ros::ros-info "arm: ~A starting" arm)))
        (send self :set-arm-val arm :enable (not enable-p))
        (send self :send-joy-feedback arm))))
  (:update-current-end-coords ()
     (let ((av (send robot :angle-vector)))
       (send robot :angle-vector
             (send robot-interface :state :potentio-vector))
       (send self :set-val 'larm-current-end-coords
             (send robot :larm :end-coords :copy-worldcoords))
       (send self :set-val 'rarm-current-end-coords
             (send robot :rarm :end-coords :copy-worldcoords))
       (send robot :angle-vector av)))
  (:grasping-p (arm)
     (and (send self :get-arm-val arm :grasping-p)
          (not (send self :get-arm-val arm :grasp-timeout-p))))
  ;; arm motion cb
  (:arm-motion-cb (&key (head t) (torso t) (safe t) (mirror nil) (gripper-button :trigger))
    (let ((visualize-arm-coords (list nil nil)))
      (if (and torso (not (or (send self :grasping-p :larm) (send self :grasping-p :rarm))))
        (cond
          ((and larm-enable rarm-enable)
           (send self :gripper-cb :larm :mirror mirror :button gripper-button)
           (send self :gripper-cb :rarm :mirror mirror :button gripper-button)
           (setq visualize-arm-coords
                 (send self :arm-cb :arms :head head :torso torso :safe safe :mirror mirror)))
          ((and larm-enable (not rarm-enable))
           (send self :gripper-cb :larm :mirror mirror :button gripper-button)
           (setf (elt visualize-arm-coords 0)
                 (send self :arm-cb :larm :head head :torso torso :safe safe :mirror mirror)))
          ((and (not larm-enable) rarm-enable)
           (send self :gripper-cb :rarm :mirror mirror :button gripper-button)
           (setf (elt visualize-arm-coords 1)
                 (send self :arm-cb :rarm :head head :torso torso :safe safe :mirror mirror)))
          (t nil))
        (progn
          (when (and larm-enable (not (send self :grasping-p :larm)))
            (send self :gripper-cb :larm :mirror mirror :button gripper-button)
            (setf (elt visualize-arm-coords 0)
                  (send self :arm-cb :larm :head head :torso nil :safe safe :mirror mirror)))
          (when (and rarm-enable (not (send self :grasping-p :rarm)))
            (send self :gripper-cb :rarm :mirror mirror :button gripper-button)
            (setf (elt visualize-arm-coords 1)
                  (send self :arm-cb :rarm :head head :torso nil :safe safe :mirror mirror)))))
      visualize-arm-coords))
  ;; motion cb
  (:motion-cb (&key (head t) (torso t) (safe-arm t) (mirror nil) (gripper-button :trigger))
    (let (visualize-arm-coords)
      (cond
        ((or larm-enable rarm-enable)
         (setq visualize-arm-coords
               (send self :arm-motion-cb :head head :torso torso :safe safe-arm :mirror mirror
                     :gripper-button gripper-button)))
        (t nil))
      visualize-arm-coords))
  ;; main loop step
  (:main-loop-step (&key (head t) (torso t) (safe-arm t) (mirror nil)
                         (enable-button :menu) (gripper-button :trigger) (visualize t))
    (let (visualize-arm-coords)
      (send self :enable-cb :mirror mirror :button enable-button)
      (setq visualize-arm-coords
            (send self :motion-cb :head head :torso torso :safe-arm safe-arm :mirror mirror
                  :gripper-button gripper-button))
      (when (and head loop-enable) (send self :head-cb))
      (send self :update-current-end-coords)
      (when visualize (send self :visualize visualize-arm-coords))))
  ;; main loop
  (:main-loop (&rest args)
    (ros::rate rate)
    (while (ros::ok)
      (send* self :main-loop-step args)
      (ros::spin-once)
      (ros::sleep)))
  ;; place holders
  (:calib-controller ()
    (return-from :calib-controller t))
  (:controller-button-p (arm button)
    (return-from :controller-button-p nil))
  (:send-joy-feedback (arm)
    (return-from :send-joy-feedback nil))
  (:get-head-ypr-angle ()
    (return-from :get-head-ypr-angle nil)))


(provide :robot-vr-interface)