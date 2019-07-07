;; -*- mode: lisp;-*-

(load "package://pr2eus/pr2-interface.l")
(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "topic_tools")


(defclass pr2-vive-interface
  :super propertied-object
  :slots (base-enable
          hmd-frame-id
          bvive-frame-id
          cvive-frame-id
          feedback-topic-name
          joy-org-topic-name
          joy-other-topic-name
          larm-grasp
          larm-trigger
          larm-prev-trigger
          larm-menu
          larm-prev-menu
          larm-trackpad
          larm-prev-trackpad
          larm-enable
          larm-vive-frame-id
          rarm-grasp
          rarm-trigger
          rarm-prev-trigger
          rarm-menu
          rarm-prev-menu
          rarm-trackpad
          rarm-prev-trackpad
          rarm-enable
          rarm-vive-frame-id
          scale
          av-tm
          av-scale
          vx
          vy
          vw
          vx-thresh
          vy-thresh
          vw-thresh
          vx-scale
          vy-scale
          vw-scale
          rate
          ))

(defmethod pr2-vive-interface
  (:init ()
    (send self :set-val 'hmd-frame-id "/hmd")
    (send self :set-val 'bvive-frame-id "/lighthouse_LHB_11CFA4E1")
    (send self :set-val 'cvive-frame-id "/lighthouse_LHB_8E924CC3")
    (send self :set-val 'feedback-topic-name "/vive/set_feedback")
    (send self :set-val 'joy-org-topic-name "/joy_org")
    (send self :set-val 'joy-other-topic-name "/joy_other")
    (send self :set-val 'larm-vive-frame-id "/controller_LHR_FD35BD42")
    (send self :set-val 'rarm-vive-frame-id "/controller_LHR_F7AFBF47")

    (send self :set-val 'scale 1.5)
    (send self :set-val 'av-tm 1000)
    (send self :set-val 'av-scale 8.0)
    (send self :set-val 'vx 0.0)
    (send self :set-val 'vy 0.0)
    (send self :set-val 'vw 0.0)
    (send self :set-val 'vx-thresh 0.3)
    (send self :set-val 'vy-thresh 0.3)
    (send self :set-val 'vw-thresh 0.3)
    (send self :set-val 'vx-scale 1.0)
    (send self :set-val 'vy-scale 1.0)
    (send self :set-val 'vw-scale 1.0)

    (send self :set-val 'base-enable nil)
    (send self :set-val 'rate 10)
    (dolist (arm (list :larm :rarm))
      (send self :set-arm-slot arm :grasp nil)
      (send self :set-arm-slot arm :trigger nil)
      (send self :set-arm-slot arm :prev-trigger nil)
      (send self :set-arm-slot arm :menu nil)
      (send self :set-arm-slot arm :prev-menu nil)
      (send self :set-arm-slot arm :trackpad nil)
      (send self :set-arm-slot arm :prev-trackpad nil)
      (send self :set-arm-slot arm :enable nil)
      (ros::subscribe (format nil "/vive~A/joy" (send self :get-arm-slot arm :vive-frame-id))
                      sensor_msgs::Joy #'send self :vive-button-cb arm))
    (setq *tfl* (instance ros::transform-listener :init))
    (ros::advertise feedback-topic-name sensor_msgs::JoyFeedback 1)
    (ros::advertise joy-other-topic-name sensor_msgs::Joy 1))
  (:get-arm-slot (arm slot)
    (send self :get-val (intern (format nil "~A-~A" (string-upcase arm) (string-upcase slot)))))
  (:set-arm-slot (arm slot val)
    (send self :set-val (intern (format nil "~A-~A" (string-upcase arm) (string-upcase slot))) val))
  (:get-arm-controller (arm)
    (cond ((eq arm :larm) :larm-controller)
          ((eq arm :rarm) :rarm-controller)
          (t nil)))
  (:arm-cb (arm &key (head t))
    (let ((target-coords (send self :get-target-coords arm :head head)))
      (when target-coords
        (send *pr2* arm :inverse-kinematics target-coords
              :rotation-axis t :revert-if-fail nil :stop 3 :debug-view nil))
      target-coords))
  (:get-target-coords (arm &key (head t))
    (let* ((hmd->vive-coords (send self :get-hmd->vive-coords arm))
           (head-coords (send (send *pr2* :head-end-coords) :copy-worldcoords))
           (pr2-height (elt (send head-coords :worldpos) 2))
           target-coords target-pos)
      (when hmd->vive-coords
        (setq target-coords (send head-coords :transform hmd->vive-coords))
        (setq target-pos (send target-coords :worldpos))
        (setq target-coords
              (make-coords :pos
                           (float-vector (* scale (elt target-pos 0))
                                         (* scale (elt target-pos 1))
                                         (- pr2-height
                                            (* scale (- pr2-height (elt target-pos 2)))))
                           :rot (send target-coords :worldrot))))
      target-coords))
  (:get-hmd->vive-coords (arm)
    (when (not (or (eq arm :larm) (eq arm :rarm)))
      (print (format nil "~A arm is not supported ~%" arm))
      (return-from :get-hmd->vive-coords nil))
    (let (coords (vive-frame-id (send self :get-arm-slot arm :vive-frame-id)))
      (send *tfl* :wait-for-transform hmd-frame-id vive-frame-id (ros::time 0) 0.1)
      (setq coords (send *tfl* :lookup-transform hmd-frame-id vive-frame-id (ros::time 0)))
      (when coords
        (send coords :transform (make-coords :rpy (float-vector 0 0 pi)) :world)
        (send coords :transform (make-coords :rpy (float-vector -pi/2 0 0)) :world)
        (send coords :transform (make-coords :rpy (float-vector 0 0 -pi/2)))
        (send coords :transform (make-coords :rpy (float-vector pi/2 0 0)))
        coords)))
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
        (pprint (send coords :rpy-angle))
        (send *pr2* :head-neck-p :joint-angle (rad2deg (* -1 (elt rpy 2))))
        (send *pr2* :head-neck-y :joint-angle (rad2deg (elt rpy 1))))))
  (:base-cb (&key (unsafe t))
    (let (msg (axes (make-list 29 :initial-element 0))
              (buttons (make-list 17 :initial-element 0)))
      (cond
        ((or larm-trigger rarm-trigger)
          (setf (elt buttons 10) 1)
          (setf (elt buttons 12)
                (if (and larm-trigger (not rarm-trigger)) 1 0))
          (setf (elt buttons 14)
                (if (and (not larm-trigger) rarm-trigger) 1 0)))
        ((or (> (abs vx) vx-thresh) (> (abs vy) vy-thresh) (> (abs vw) vw-thresh))
          ;; for unsafe teleop
          (when unsafe (setf (elt buttons 9) 1))
          (setf (elt buttons 10) 1)
          (setf (elt axes 3) (* vx-scale (if (> (abs vx) vx-thresh) vx 0.0)))
          (setf (elt axes 2) (* vy-scale (if (> (abs vy) vy-thresh) vy 0.0)))
          (setf (elt axes 0) (* vw-scale (if (> (abs vw) vw-thresh) vw 0.0))))
        (t nil))
      (setq msg (instance sensor_msgs::Joy :init))
      (send msg :header :stamp (ros::time-now))
      (send msg :axes axes)
      (send msg :buttons buttons)
      (ros::publish joy-other-topic-name msg)))
  (:gripper-cb (arm)
    (let ((vive-trigger-p (send self :vive-trigger-p arm))
          (grasp-p (send self :get-arm-slot arm :grasp)))
      (when vive-trigger-p
        (if grasp-p
          (send *ri* :stop-grasp arm :wait nil)
          (send *ri* :start-grasp arm :wait nil))
        (send self :set-arm-slot arm :grasp (not grasp-p)))))
  (:enable-cb ()
    (send self :enable-arm :larm)
    (send self :enable-arm :rarm))
  (:enable-arm (arm)
    (let ((vive-menu-p (send self :vive-menu-p arm))
          (enable-p (send self :get-arm-slot arm :enable)))
      (when vive-menu-p
        (when enable-p
          (send *ri* :cancel-angle-vector
                :controller-type (send self :get-arm-controller arm)))
        (send self :set-arm-slot arm :enable (not enable-p))
        (send self :send-joy-feedback arm))))
  (:vive-button-cb (arm msg)
    (send self :set-arm-slot arm :prev-trigger (send self :get-arm-slot arm :trigger))
    (send self :set-arm-slot arm :prev-menu (send self :get-arm-slot arm :menu))
    (send self :set-arm-slot arm :prev-trackpad (send self :get-arm-slot arm :trackpad))
    (send self :set-arm-slot arm :trigger (> (elt (send msg :buttons) 1) 0))
    (send self :set-arm-slot arm :menu (> (elt (send msg :buttons) 0) 0))
    (send self :set-arm-slot arm :trackpad (> (elt (send msg :buttons) 2) 0))
    (cond
      ((eq arm :larm)
       (send self :set-val 'vw
             (if (send self :get-arm-slot arm :trackpad)
               (* -1 (elt (send msg :axes) 0)) 0)))
      ((eq arm :rarm)
       (send self :set-val 'vx
             (if (send self :get-arm-slot arm :trackpad)
               (elt (send msg :axes) 1) 0))
       (send self :set-val 'vy
             (if (send self :get-arm-slot arm :trackpad)
               (* -1 (elt (send msg :axes) 0)) 0)))
      (t nil)))
  (:vive-trigger-p (arm)
    (let ((trigger (send self :get-arm-slot arm :trigger))
          (prev-trigger (send self :get-arm-slot arm :prev-trigger)))
      (and (not (eq trigger prev-trigger)) trigger)))
  (:vive-menu-p (arm)
    (let ((menu (send self :get-arm-slot arm :menu))
          (prev-menu (send self :get-arm-slot arm :prev-menu)))
      (and (not (eq menu prev-menu)) menu)))
  (:vive-trackpad-p (arm)
    (let ((trackpad (send self :get-arm-slot arm :trackpad))
          (prev-trackpad (send self :get-arm-slot arm :prev-trackpad)))
      (and (not (eq trackpad prev-trackpad)) trackpad)))
  (:send-joy-feedback (&optional (arm :larm))
    (let (msg (id (if (eq arm :larm) 2 1)))
      (setq msg (instance sensor_msgs::JoyFeedback :init
                          :type 1 :id id :intensity 3000))
      (ros::publish feedback-topic-name msg)))
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
  (:main-loop-step (&key (head t) (base t) (unsafe t))
    (let (larm-coords rarm-coords)
      (when head (send self :head-cb))
      (send self :enable-cb)
      (if (and (not larm-enable) (not rarm-enable))
        (progn
          (when base
            (unless base-enable (send self :switch-joy-to-vive))
            (send self :set-val 'base-enable t)))
        (progn
          (when base
            (when base-enable (send self :switch-joy-to-ps3joy))
            (send self :set-val 'base-enable nil))
          (when larm-enable
            (setq larm-coords (send self :arm-cb :larm :head head))
            (when larm-coords
                  (send larm-coords :draw-on :flush t :size 50
                        :color #f(0 1 0) :width 5)))
          (when rarm-enable
            (setq rarm-coords (send self :arm-cb :rarm :head head))
            (when rarm-coords
                  (send rarm-coords :draw-on :flush t :size 50
                        :color #f(1 0 0) :width 5)))))
      (cond
        ((and larm-enable rarm-enable)
          (send self :gripper-cb :larm)
          (send self :gripper-cb :rarm)
          (send *ri* :angle-vector (send *pr2* :angle-vector) av-tm
                :larm-controller 0 :min-time 0.1 :scale av-scale)
          (send *ri* :angle-vector (send *pr2* :angle-vector) av-tm
                :rarm-controller 0 :min-time 0.1 :scale av-scale))
        ((and larm-enable (not rarm-enable))
          (send self :gripper-cb :larm)
          (send *ri* :angle-vector (send *pr2* :angle-vector) av-tm
                :larm-controller 0 :min-time 0.1 :scale av-scale))
        ((and (not larm-enable) rarm-enable)
          (send self :gripper-cb :rarm)
          (send *ri* :angle-vector (send *pr2* :angle-vector) av-tm
                :rarm-controller 0 :min-time 0.1 :scale av-scale))
        (base-enable
          (when base (send self :base-cb :unsafe unsafe)))
        (t nil))
      (when head (send *ri* :angle-vector (send *pr2* :angle-vector) av-tm
                       :head-controller 0 :min-time 0.1 :scale av-scale))))
  (:main-loop (&key (head t) (base t) (unsafe t) (pre-process nil) (post-process nil))
    (ros::rate rate)
    (while (ros::ok)
      (when pre-process (eval pre-process))
      (send *ti* :main-loop-step :head head :base base :unsafe unsafe)
      (when post-process (eval post-process))
      (ros::spin-once)
      (ros::sleep))))

(defun pr2-vive-init ()
  (pr2-init)
  (setq *ti* (instance pr2-vive-interface :init)))
