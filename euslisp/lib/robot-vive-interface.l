;; -*- mode: lisp;-*-

(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "topic_tools")

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(defclass robot-vive-interface
  :super robot-vr-interface
  :slots (hmd-frame-id
          vrbase-device-id
          larm-controller-device-id
          rarm-controller-device-id
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
          vrbase->shoulder-x
          vrbase->shoulder-z
          ))


(defmethod robot-vive-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for calibration
      (send self :set-val 'vrbase->shoulder-x nil)
      (send self :set-val 'vrbase->shoulder-z nil)
      ;; for vive
      (send self :set-val 'hmd-frame-id "hmd")
      (send self :set-val 'vrbase-device-id (ros::get-param "/eus_vive/b_lighthouse_id"))
      (send self :set-arm-val :larm :controller-device-id
            (ros::get-param "/eus_vive/l_controller_id"))
      (send self :set-arm-val :rarm :controller-device-id
            (ros::get-param "/eus_vive/r_controller_id"))
      (send self :set-val 'feedback-topic-name "/vive/set_feedback")
      (if vrbase-device-id
        (send self :set-val 'vrbase-frame-id (format nil "lighthouse_LHB_~A" vrbase-device-id))
        (ros::ros-warn "param: /eus_vive/b_lighthouse_id is not set"))))
  (:ros-init ()
    (prog1
      (send-super :ros-init)
      (ros::advertise feedback-topic-name sensor_msgs::JoyFeedback 1)
      (if larm-controller-device-id
        (progn
          (send self :set-arm-val :larm :controller-frame-id
                (format nil "controller_LHR_~A" larm-controller-device-id))
          (ros::subscribe (format nil "/vive/~A/joy"
                                  (send self :get-arm-val :larm :controller-frame-id))
                          sensor_msgs::Joy #'send self :controller-button-cb :larm))
        (ros::ros-warn "param: /eus_vive/l_controller_id is not set"))
      (if rarm-controller-device-id
        (progn
          (send self :set-arm-val :rarm :controller-frame-id
                (format nil "controller_LHR_~A" rarm-controller-device-id))
          (ros::subscribe (format nil "/vive/~A/joy"
                                  (send self :get-arm-val :rarm :controller-frame-id))
                          sensor_msgs::Joy #'send self :controller-button-cb :rarm))
        (ros::ros-warn "param: /eus_vive/r_controller_id is not set"))))
  ;; redefine :reset-arm-val
  (:reset-arm-val (arm)
    (send-super :reset-arm-val arm)
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
  ;; :get-target-coords
  (:get-target-coords (arm &key (head t) (mirror nil))
    (let (target-pos target-rot target-coords)
      (if head
        (let ((hmd->controller-coords
                (send self :get-hmd->controller-coords
                      (if mirror (send self :get-opposite-arm arm) arm)))
              (head-coords (send self :get-head-end-coords))
               controller-coords)
          (if hmd->controller-coords
            (progn
              (setq controller-coords (send head-coords :transform hmd->controller-coords))
              (setq target-pos (send controller-coords :worldpos))
              (setq target-rot (send controller-coords :worldrot)))))
        (let ((vrbase->controller-coords
                (send self :get-vrbase->controller-coords
                      (if mirror (send self :get-opposite-arm arm) arm) :wait-trigger nil))
              vrbase->controller-pos)
          (if vrbase->controller-coords
            (progn
              (send vrbase->controller-coords
                    :transform (make-coords :rpy (float-vector pi/2 0 pi/2)) :world)
              (send vrbase->controller-coords :transform
                    (make-coords :rpy (float-vector 0 pi/2 0)))
              (send vrbase->controller-coords :transform
                    (make-coords :rpy (float-vector 0 0 -pi/2)))
              (setq vrbase->controller-pos (send vrbase->controller-coords :worldpos))
              (setq target-pos
                    (float-vector (- (elt vrbase->controller-pos 0) vrbase->shoulder-x)
                                  (elt vrbase->controller-pos 1)
                                  (- (elt vrbase->controller-pos 2) vrbase->shoulder-z)))
              (setq target-rot (send vrbase->controller-coords :worldrot))))))
      (if (and target-pos target-rot)
        (progn
          (setq target-coords
                (send self :get-target-coords-from-pos-rot
                      target-pos target-rot :head head :mirror mirror))
          ;; rotate pi/4 for vive controller
          (send target-coords :rotate (/ pi 4.0) :y)))
      target-coords))
  ;; :get-head-ypr-angle
  (:get-head-ypr-angle ()
    (let ((coords (send self :get-vrbase->hmd-coords)) rpy-angle)
      (if coords
        (progn
          (setq rpy-angle
                (if (> pi/2 (abs (elt (car (send coords :rpy-angle)) 0)))
                  (car (send coords :rpy-angle))
                  (cadr (send coords :rpy-angle))))
          (list (elt rpy-angle 1) (* -1 (elt rpy-angle 2)) 0)))))
  ;; coordinate function for vive
  (:get-hmd->controller-coords (arm)
    (if (not (or (eq arm :larm) (eq arm :rarm)))
      (progn
        (ros::ros-error (format nil "~A arm is not supported ~%" arm))
        (return-from :get-hmd->controller-coords nil)))
    (let ((controller-frame-id (send self :get-arm-val arm :controller-frame-id))
          coords)
      (if (null controller-frame-id)
        (progn
          (ros::ros-warn "Controller frame id is not set properly.")
          (ros::ros-warn "controller-frame-id: ~A" controller-frame-id)
          (return-from :get-hmd->controller-coords nil)))
      (send tfl :wait-for-transform hmd-frame-id controller-frame-id (ros::time 0) 0.1)
      (setq coords (send tfl :lookup-transform hmd-frame-id controller-frame-id (ros::time 0)))
      (if coords
        (progn
          (send coords :transform (make-coords :rpy (float-vector 0 0 pi)) :world)
          (send coords :transform (make-coords :rpy (float-vector -pi/2 0 0)) :world)
          (send coords :transform (make-coords :rpy (float-vector 0 0 -pi/2)))
          (send coords :transform (make-coords :rpy (float-vector pi/2 0 0)))))
      coords))
  ;; coordinate function for vive
  (:get-vrbase->controller-coords (arm &key (wait-trigger nil) (wait-time 0.1))
    (let ((controller-frame-id (send self :get-arm-val arm :controller-frame-id))
          (start-time (ros::time 0))
          coords controller-trigger-button-p)
      (if (or (null vrbase-frame-id) (null controller-frame-id))
        (progn
          (ros::ros-warn "Frame ids are not set properly.")
          (ros::ros-warn "vrbase-frame-id: ~A" vrbase-frame-id)
          (ros::ros-warn "controller-frame-id: ~A" controller-frame-id)
          (return-from :get-vrbase->controller-coords nil)))
      (if wait-trigger
        (progn
          (ros::ros-info "Waiting for trigger: ~A~%" (string-downcase arm))
          (while (and (ros::ok) (not controller-trigger-button-p))
            (setq controller-trigger-button-p
                  (send self :controller-trigger-button-p arm :button-toggle t))
            (ros::spin-once)
            (ros::sleep))))
      (send tfl :wait-for-transform vrbase-frame-id controller-frame-id start-time wait-time)
      (setq coords (send tfl :lookup-transform vrbase-frame-id controller-frame-id start-time))
      coords))
  ;; coordinate function for vive
  (:get-vrbase->hmd-coords ()
    (let (coords)
      (if (null vrbase-frame-id)
        (progn
          (ros::ros-warn "VR base frame id is not set properly.")
          (ros::ros-warn "vrbase-frame-id: ~A" vrbase-frame-id)
          (return-from :get-vrbase->hmd-coords nil)))
      (send tfl :wait-for-transform vrbase-frame-id hmd-frame-id (ros::time 0) 0.1)
      (setq coords (send tfl :lookup-transform vrbase-frame-id hmd-frame-id (ros::time 0)))
      (if coords
        (send coords :transform (make-coords :rpy (float-vector 0 pi 0)) :world))))
  ;; :calib-controller
  (:calib-controller (&optional (arm :rarm))
    (let (first-coords second-coords)
      (ros::rate rate)
      (ros::ros-info "Calibration start: ~A~%" (string-downcase arm))
      (ros::ros-info "Stretch your ~A arm and press trigger.~%" (string-downcase arm))
      (send robot-interface :speak "Calibration starts." :wait t :volume 0.6)
      (send robot-interface :speak
            (format nil "Please stretch your ~A arm and press trigger."
                    (if (eq arm :larm) "left" "right"))
            :wait nil :volume 0.6)
      (setq first-coords (send self :get-vrbase->controller-coords arm :wait-trigger t))
      (ros::sleep)
      (send robot-interface :speak
            (format nil "Please fold your ~A arm and press trigger."
                    (if (eq arm :larm) "left" "right"))
            :wait nil :volume 0.6)
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
          (send robot-interface :speak "Calibration succeeded." :wait nil :volume 0.6)
          (ros::ros-info "1st coords: ~A" (send first-coords :worldpos))
          (ros::ros-info "2nd coords: ~A" (send second-coords :worldpos))
          (send self :send-joy-feedback arm)
          t)
        (progn
          (ros::ros-error "Calibration is failed.~%")
          (send robot-interface :speak "Calibration failed." :wait t :volume 0.6)
          (ros::ros-error "1st coords: ~A" (send first-coords :worldpos))
          (ros::ros-error "2nd coords: ~A" (send second-coords :worldpos))
          (ros::duration-sleep 1)
          (send self :send-joy-feedback arm)
          nil))))
  ;; controller button callbacks
  (:controller-button-cb (arm msg)
    (if (and loop-enable (send self :get-arm-val arm :loop-enable))
      (progn
        (send self :set-arm-val arm :prev-trigger (send self :get-arm-val arm :trigger))
        (send self :set-arm-val arm :prev-menu (send self :get-arm-val arm :menu))
        (send self :set-arm-val arm :prev-trackpad (send self :get-arm-val arm :trackpad))
        (send self :set-arm-val arm :prev-grip (send self :get-arm-val arm :grip))
        (send self :set-arm-val arm :trigger (> (elt (send msg :buttons) 1) 0))
        (send self :set-arm-val arm :menu (> (elt (send msg :buttons) 0) 0))
        (send self :set-arm-val arm :trackpad (> (elt (send msg :buttons) 2) 0))
        (send self :set-arm-val arm :grip (> (elt (send msg :buttons) 3) 0)))))
  (:controller-trigger-button-p (arm &key (button-toggle t))
    (send self :controller-button-common-p
          (if (eq arm :larm) 'larm-trigger 'rarm-trigger)
          :button-toggle button-toggle))
  (:controller-menu-button-p (arm &key (button-toggle t))
    (send self :controller-button-common-p
          (if (eq arm :larm) 'larm-menu 'rarm-menu)
          :button-toggle button-toggle))
  (:controller-trackpad-button-p (arm &key (button-toggle t))
    (send self :controller-button-common-p
          (if (eq arm :larm) 'larm-trackpad 'rarm-trackpad)
          :button-toggle button-toggle))
  (:controller-grip-button-p (arm &key (button-toggle t))
    (send self :controller-button-common-p
          (if (eq arm :larm) 'larm-grip 'rarm-grip)
          :button-toggle button-toggle))
  ;; vive vibration feedback
  (:send-joy-feedback (arm)
    (let (msg (id (if (eq arm :larm) 2 1)))
      (setq msg (instance sensor_msgs::JoyFeedback :init
                          :type 1 :id id :intensity 3000))
      (ros::publish feedback-topic-name msg))))


(provide :robot-vive-interface)
