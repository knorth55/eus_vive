;; -*- mode: lisp;-*-

(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "topic_tools")

(load "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(defclass robot-vive-interface
  :super robot-vr-interface
  :slots (hmd-frame-id
          vrbase-frame-id
          larm-controller-frame-id
          rarm-controller-frame-id
          feedback-topic-name
          trigger-wait-count
          menu-wait-count
          trackpad-wait-count
          grip-wait-count
          larm-trigger
          larm-prev-trigger
          larm-trigger-count
          larm-menu
          larm-prev-menu
          larm-menu-count
          larm-trackpad
          larm-prev-trackpad
          larm-trackpad-count
          larm-grip
          larm-prev-grip
          larm-grip-count
          rarm-trigger
          rarm-prev-trigger
          rarm-trigger-count
          rarm-menu
          rarm-prev-menu
          rarm-menu-count
          rarm-trackpad
          rarm-prev-trackpad
          rarm-trackpad-count
          rarm-grip
          rarm-prev-grip
          rarm-grip-count
          head->shoulder-x-distance
          head->shoulder-z-distance
          vrbase->shoulder-x
          vrbase->shoulder-z
          ))


(defmethod robot-vive-interface
  (:init (&key (loop-enable t))
    ;; for calibration
    (send self :set-val 'vrbase->shoulder-x nil)
    (send self :set-val 'vrbase->shoulder-z nil)
    ;; for vive
    (send self :set-val 'hmd-frame-id "hmd")
    (send self :set-val 'vrbase-frame-id
          (format nil "lighthouse_LHB_~A" (ros::get-param "/eus_vive/b_lighthouse_id")))
    (send self :set-val 'larm-controller-frame-id
          (format nil "controller_LHR_~A" (ros::get-param "/eus_vive/l_controller_id")))
    (send self :set-val 'rarm-controller-frame-id
          (format nil "controller_LHR_~A" (ros::get-param "/eus_vive/r_controller_id")))
    (send self :set-val 'feedback-topic-name "/vive/set_feedback")
    (dolist (arm (list :larm :rarm))
      (ros::subscribe (format nil "/vive/~A/joy" (send self :get-arm-val arm :controller-frame-id))
                      sensor_msgs::Joy #'send self :controller-button-cb arm))
    (ros::advertise feedback-topic-name sensor_msgs::JoyFeedback 1)
    (send-super :init :loop-enable loop-enable))
  (:reset-arm (arm)
    (send-super :reset-arm arm)
    (send self :set-arm-val arm :trigger nil)
    (send self :set-arm-val arm :prev-trigger nil)
    (send self :set-arm-val arm :trigger-count 0)
    (send self :set-arm-val arm :menu nil)
    (send self :set-arm-val arm :prev-menu nil)
    (send self :set-arm-val arm :menu-count 0)
    (send self :set-arm-val arm :trackpad nil)
    (send self :set-arm-val arm :prev-trackpad nil)
    (send self :set-arm-val arm :trackpad-count 0)
    (send self :set-arm-val arm :grip nil)
    (send self :set-arm-val arm :prev-grip nil)
    (send self :set-arm-val arm :grip-count 0))
  (:get-target-coords (arm &key (head t) (mirror nil))
    (let* ((head-coords (send self :get-head-end-coords))
           (robot-height (elt (send head-coords :worldpos) 2))
          target-pos target-rot target-coords)
      (if head
        (let ((hmd->controller-coords
                (send self :get-hmd->controller-coords
                      (if mirror (send self :get-opposite-arm arm) arm)))
               controller-coords)
          (when hmd->controller-coords
            (setq controller-coords (send head-coords :transform hmd->controller-coords))
            (setq target-pos (send controller-coords :worldpos))
            (setq target-rot (send controller-coords :worldrot))))
        (let ((base->controller-coords
                (send self :get-vrbase->controller-coords
                      (if mirror (send self :get-opposite-arm arm) arm) :wait-trigger nil))
              base->controller-pos)
          (when base->controller-coords
            (send base->controller-coords
                  :transform (make-coords :rpy (float-vector pi/2 0 pi/2)) :world)
            (send base->controller-coords :transform (make-coords :rpy (float-vector 0 pi/2 0)))
            (send base->controller-coords :transform (make-coords :rpy (float-vector 0 0 -pi/2)))
            (setq base->controller-pos (send base->controller-coords :worldpos))
            (setq target-pos
                  (float-vector (- (elt base->controller-pos 0) base->shoulder-x)
                                (elt base->controller-pos 1)
                                (- (+ robot-height (elt base->controller-pos 2))
                                   (+ base->shoulder-z head->shoulder-z-distance))))
            (setq target-rot (send base->controller-coords :worldrot)))))
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
                           :rot target-rot))
        (send target-coords :rotate (/ pi 4.0) :y))
      target-coords))
  (:get-hmd->controller-coords (arm)
    (when (not (or (eq arm :larm) (eq arm :rarm)))
      (ros::ros-error (format nil "~A arm is not supported ~%" arm))
      (return-from :get-hmd->controller-coords nil))
    (let ((controller-frame-id (send self :get-arm-val arm :controller-frame-id))
          coords)
      (send tfl :wait-for-transform hmd-frame-id controller-frame-id (ros::time 0) 0.1)
      (setq coords (send tfl :lookup-transform hmd-frame-id controller-frame-id (ros::time 0)))
      (when coords
        (send coords :transform (make-coords :rpy (float-vector 0 0 pi)) :world)
        (send coords :transform (make-coords :rpy (float-vector -pi/2 0 0)) :world)
        (send coords :transform (make-coords :rpy (float-vector 0 0 -pi/2)))
        (send coords :transform (make-coords :rpy (float-vector pi/2 0 0)))
        coords)))
  (:get-vrbase->controller-coords (arm &key (wait-trigger nil) (wait-time 0.1))
    (let ((controller-frame-id (send self :get-arm-val arm :controller-frame-id))
          (start-time (ros::time 0))
          coords controller-trigger-p)
      (when wait-trigger
        (ros::ros-info "Waiting for trigger: ~A~%" (string-downcase arm))
        (while (and (ros::ok) (not controller-trigger-p))
          (setq controller-trigger-p (send self :controller-trigger-p arm))
          (ros::spin-once)
          (ros::sleep)))
      (send tfl :wait-for-transform base-frame-id controller-frame-id start-time wait-time)
      (setq coords (send tfl :lookup-transform base-frame-id controller-frame-id start-time))
      coords))
  (:get-vrbase->hmd-coords ()
    (let (coords)
      (send tfl :wait-for-transform base-frame-id hmd-frame-id (ros::time 0) 0.1)
      (setq coords (send tfl :lookup-transform base-frame-id hmd-frame-id (ros::time 0)))
      (when coords
        (send coords :transform (make-coords :rpy (float-vector 0 pi 0)) :world))))
  (:calib-controller (&optional (arm :rarm))
    (let (first-coords second-coords)
      (ros::rate rate)
      (ros::ros-info "Calibration start: ~A~%" (string-downcase arm))
      (ros::ros-info "Stretch your ~A arm and press trigger.~%" (string-downcase arm))
      (send robot-interface :speak "Calibration starts." :wait t)
      (send robot-interface :speak
            (format nil "Please stretch your ~A arm and press trigger."
                    (if (eq arm :larm) "left" "right")))
      (setq first-coords (send self :get-vrbase->controller-coords arm :wait-trigger t))
      (ros::sleep)
      (send robot-interface :speak
            (format nil "Please fold your ~A arm and press trigger."
                    (if (eq arm :larm) "left" "right")))
      (ros::ros-info "Fold your ~A arm and press trigger.~%" (string-downcase arm))
      (setq second-coords (send self :get-vrbase->controller-coords arm :wait-trigger t))
      (if (and (and first-coords second-coords)
               (> (elt (send first-coords :worldpos) 2)
                  (elt (send second-coords :worldpos) 2)))
        (progn
          (send self :set-val 'scale
                (/ (send self :get-val 'arm-length)
                   (norm (v- (send second-coords :worldpos) (send first-coords :worldpos)))))
          (ros::ros-info "Calibrate scale: ~A~%" (send self :get-val 'scale))
          (send self :set-val 'vrbase->shoulder-x
                (- (elt (send second-coords :worldpos) 2) head->shoulder-x-distance))
          (send self :set-val 'vrbase->shoulder-z (elt (send second-coords :worldpos) 1))
          (ros::ros-info "Calibration end: ~A~%" (string-downcase arm))
          (send robot-interface :speak "Calibration succeeded.")
          (ros::ros-info "1st coords: ~A" (send first-coords :worldpos))
          (ros::ros-info "2nd coords: ~A" (send second-coords :worldpos))
          (send self :send-joy-feedback arm)
          t)
        (progn
          (ros::ros-error "Calibration is failed.~%")
          (send robot-interface :speak "Calibration failed." :wait t)
          (ros::ros-error "1st coords: ~A" (send first-coords :worldpos))
          (ros::ros-error "2nd coords: ~A" (send second-coords :worldpos))
          (ros::duration-sleep 1)
          (send self :send-joy-feedback arm)
          nil))))
  (:controller-button-cb (arm msg)
    (when loop-enable
      (send self :set-arm-val arm :prev-trigger (send self :get-arm-val arm :trigger))
      (send self :set-arm-val arm :prev-menu (send self :get-arm-val arm :menu))
      (send self :set-arm-val arm :prev-trackpad (send self :get-arm-val arm :trackpad))
      (send self :set-arm-val arm :prev-grip (send self :get-arm-val arm :grip))
      (send self :set-arm-val arm :trigger (> (elt (send msg :buttons) 1) 0))
      (send self :set-arm-val arm :menu (> (elt (send msg :buttons) 0) 0))
      (send self :set-arm-val arm :trackpad (> (elt (send msg :buttons) 2) 0))
      (send self :set-arm-val arm :grip (> (elt (send msg :buttons) 3) 0))))
  (:controller-button-p (arm button)
    (cond
      ((eq button :trigger) (send self :controller-trigger-p arm))
      ((eq button :menu) (send self :controller-menu-p arm))
      ((eq button :trackpad) (send self :controller-trackpad-p arm))
      ((eq button :grip) (send self :controller-grip-p arm))
      (t nil)))
  (:controller-trigger-p (arm)
    (let ((trigger (send self :get-arm-val arm :trigger))
          (prev-trigger (send self :get-arm-val arm :prev-trigger))
          (trigger-count (send self :get-arm-val arm :trigger-count)))
      (if (> trigger-count 0)
        (progn
          (send self :set-arm-val arm :trigger-count (- trigger-count 1))
          nil)
        (let ((controller-trigger-p (and (not (eq trigger prev-trigger)) trigger)))
          (when controller-trigger-p (send self :set-arm-val arm :trigger-count trigger-wait-count))
          controller-trigger-p))))
  (:controller-menu-p (arm)
    (let ((menu (send self :get-arm-val arm :menu))
          (prev-menu (send self :get-arm-val arm :prev-menu))
          (menu-count (send self :get-arm-val arm :menu-count)))
      (if (> menu-count 0)
        (progn
          (send self :set-arm-val arm :menu-count (- menu-count 1))
          nil)
        (let ((controller-menu-p (and (not (eq menu prev-menu)) menu)))
          (when controller-menu-p (send self :set-arm-val arm :menu-count menu-wait-count))
          controller-menu-p))))
  (:controller-trackpad-p (arm)
    (let ((trackpad (send self :get-arm-val arm :trackpad))
          (prev-trackpad (send self :get-arm-val arm :prev-trackpad))
          (trackpad-count (send self :get-arm-val arm :trackpad-count)))
      (if (> trackpad-count 0)
        (progn
          (send self :set-arm-val arm :trackpad-count (- trackpad-count 1))
          nil)
        (let ((controller-trackpad-p (and (not (eq trackpad prev-trackpad)) trackpad)))
          (when controller-trackpad-p (send self :set-arm-val arm :trackpad-count trackpad-wait-count))
          controller-trackpad-p))))
  (:controller-grip-p (arm)
    (let ((grip (send self :get-arm-val arm :grip))
          (prev-grip (send self :get-arm-val arm :prev-grip))
          (grip-count (send self :get-arm-val arm :grip-count)))
      (if (> grip-count 0)
        (progn
          (send self :set-arm-val arm :grip-count (- grip-count 1))
          nil)
        (let ((controller-grip-p (and (not (eq grip prev-grip)) grip)))
          (when controller-grip-p (send self :set-arm-val arm :grip-count grip-wait-count))
          controller-grip-p))))
  (:send-joy-feedback (arm)
    (let (msg (id (if (eq arm :larm) 2 1)))
      (setq msg (instance sensor_msgs::JoyFeedback :init
                          :type 1 :id id :intensity 3000))
      (ros::publish feedback-topic-name msg))))


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
  (:init (&rest args)
    (send-super* :init args)
    ;; for move base
    (send self :set-val 'joy-org-topic-name "/joy_org")
    (send self :set-val 'joy-other-topic-name "/joy_other")
    (ros::advertise joy-other-topic-name sensor_msgs::Joy 1))
  (:reset (&key (loop-enable t))
    (send-super :reset :loop-enable loop-enable)
    (send self :set-val 'vx 0.0)
    (send self :set-val 'vy 0.0)
    (send self :set-val 'vw 0.0)
    (send self :set-val 'base-enable nil))
  (:base-cb (&key (safe t) (mirror nil))
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
         (when (and (not safe) larm-trigger) (setf (elt buttons 9) 1))
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
  (:controller-button-cb (arm msg)
    (send-super :controller-button-cb arm msg)
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
  (:switch-joy-to-controller ()
    (send self :switch-joy joy-other-topic-name))
  (:switch-joy-to-ps3joy ()
    (send self :switch-joy joy-org-topic-name))
  (:enable-cb (&key (mirror nil) (base t) (button :menu))
    (send-super :enable-cb :mirror mirror :button button)
    (when base (send self :enable-base)))
  (:enable-base ()
    (cond
      ((and (not larm-enable) (not rarm-enable))
       (unless base-enable (send self :switch-joy-to-controller))
       (send self :set-val 'base-enable t))
      ((or larm-enable rarm-enable)
       (when base-enable (send self :switch-joy-to-ps3joy))
       (send self :set-val 'base-enable nil))
      (t nil)))
  (:motion-cb (&key (head t) (torso t) (base t) (safe-arm t) (safe-base nil) (mirror nil)
                    (gripper-button :trigger))
    (let (visualize-arm-coords)
      (cond
        ((or larm-enable rarm-enable)
         (setq visualize-arm-coords
               (send self :arm-motion-cb :head head :torso torso :safe safe-arm :mirror mirror
                     :gripper-button gripper-button)))
        ((and loop-enable base-enable)
         (when base (send self :base-cb :safe safe-base :mirror mirror)))
        (t nil))
      visualize-arm-coords))
  (:main-loop-step (&key (head t) (torso t) (base t) (safe-arm t) (safe-base nil) (mirror nil)
                         (enable-button :menu) (gripper-button :trigger) (visualize t))
    (let (visualize-arm-coords)
      (send self :update-current-end-coords)
      (send self :enable-cb :mirror mirror :base base :button enable-button)
      (setq visualize-arm-coords
            (send self :motion-cb :head head :torso torso
                  :base base :safe-arm safe-arm :safe-base safe-base :mirror mirror
                  :gripper-button gripper-button))
      (when (and head loop-enable) (send self :head-cb))
      (when visualize (send self :visualize visualize-arm-coords)))))

(provide :robot-vive-interface)
