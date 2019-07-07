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
          prev-larm-trigger
          larm-menu
          prev-larm-menu
          larm-enable
          lvive-frame-id
          rarm-grasp
          rarm-trigger
          prev-rarm-trigger
          rarm-menu
          prev-rarm-menu
          rarm-enable
          rvive-frame-id
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
          ))

(defmethod pr2-vive-interface
  (:init ()
    (setq base-enable nil)
    (setq hmd-frame-id "/hmd")
    (setq bvive-frame-id "/lighthouse_LHB_11CFA4E1")
    (setq cvive-frame-id "/lighthouse_LHB_8E924CC3")
    (setq feedback-topic-name "/vive/set_feedback")
    (setq joy-org-topic-name "/joy_org")
    (setq joy-other-topic-name "/joy_other")

    (setq larm-grasp nil)
    (setq larm-trigger nil)
    (setq larm-menu nil)
    (setq prev-larm-trigger nil)
    (setq prev-larm-menu nil)
    (setq larm-enable nil)
    (setq lvive-frame-id "/controller_LHR_FD35BD42")

    (setq rarm-grasp nil)
    (setq rarm-trigger nil)
    (setq rarm-menu nil)
    (setq prev-rarm-trigger nil)
    (setq prev-rarm-menu nil)
    (setq rarm-enable nil)
    (setq rvive-frame-id "/controller_LHR_F7AFBF47")

    (setq scale 1.5)
    (setq av-tm 1000)
    (setq av-scale 8.0)
    (setq vx 0.0)
    (setq vy 0.0)
    (setq vw 0.0)
    (setq vx-thresh 0.3)
    (setq vy-thresh 0.3)
    (setq vw-thresh 0.3)
    (setq vx-scale 1.0)
    (setq vy-scale 1.0)
    (setq vw-scale 1.0)

    (setq *tfl* (instance ros::transform-listener :init))
    (ros::advertise feedback-topic-name sensor_msgs::JoyFeedback 1)
    (ros::advertise joy-other-topic-name sensor_msgs::Joy 1)
    (ros::subscribe (format nil "/vive~A/joy" lvive-frame-id)
                    sensor_msgs::Joy #'send self :vive-button-cb :larm)
    (ros::subscribe (format nil "/vive~A/joy" rvive-frame-id)
                    sensor_msgs::Joy #'send self :vive-button-cb :rarm))
  (:arm-cb (arm &key (head t))
    (let (target-coords)
      (setq target-coords
            (if head
              (send self :get-target-coords-with-head arm)
              (send self :get-target-coords arm)))
      (when target-coords
        (send *pr2* arm :inverse-kinematics target-coords
              :rotation-axis t :revert-if-fail nil :stop 3 :debug-view nil))
      target-coords))
  (:get-target-coords-with-head (arm &key (head t))
    (let (hmd->vive-coords head-coords pr2-heigh target-coords target-pos)
      (setq hmd->vive-coords (send self :get-hmd->vive-coords arm))
      (setq head-coords (send (send *pr2* :head-end-coords) :copy-worldcoords))
      (setq pr2-height (elt (send head-coords :worldpos) 2))
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
    (let (coords (vive-frame-id (if (eq arm :larm) lvive-frame-id rvive-frame-id)))
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
    (if (eq arm :larm)
      (when (and (not (eq larm-trigger prev-larm-trigger)) larm-trigger)
        (if larm-grasp
          (send *ri* :stop-grasp :larm :wait nil)
          (send *ri* :start-grasp :larm :wait nil))
        (setq larm-grasp (not larm-grasp)))
      (when (and (not (eq rarm-trigger prev-rarm-trigger)) rarm-trigger)
        (if rarm-grasp
          (send *ri* :stop-grasp :rarm :wait nil)
          (send *ri* :start-grasp :rarm :wait nil))
        (setq rarm-grasp (not rarm-grasp)))))
  (:enable-cb ()
    (when (and (not (eq larm-menu prev-larm-menu)) larm-menu)
      (setq larm-enable (not larm-enable))
      (send self :send-joy-feedback :larm))
    (unless larm-enable (send *ri* :cancel-angle-vector :controller-type :larm-controller))
    (when (and (not (eq rarm-menu prev-rarm-menu)) rarm-menu)
      (setq rarm-enable (not rarm-enable))
      (send self :send-joy-feedback :rarm))
    (unless rarm-enable (send *ri* :cancel-angle-vector :controller-type :rarm-controller)))
  (:vive-button-cb (arm msg)
    (if (eq arm :larm)
      (progn
        (setq prev-larm-trigger larm-trigger)
        (setq prev-larm-menu larm-menu)
        (setq larm-trigger (> (elt (send msg :buttons) 1) 0))
        (setq larm-menu (> (elt (send msg :buttons) 0) 0))
        (setq vw (* -1 (elt (send msg :axes) 0))))
      (progn
        (setq prev-rarm-trigger rarm-trigger)
        (setq prev-rarm-menu rarm-menu)
        (setq rarm-trigger (> (elt (send msg :buttons) 1) 0))
        (setq rarm-menu (> (elt (send msg :buttons) 0) 0))
        (setq vx (elt (send msg :axes) 1))
        (setq vy (* -1 (elt (send msg :axes) 0))))))
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
  (:main-loop-step (&key (head t) (base t))
    (let (larm-coords rarm-coords)
      (when head (send self :head-cb))
      (send self :enable-cb)
      (if (and (not larm-enable) (not rarm-enable))
        (progn
          (when base
            (unless base-enable (send self :switch-joy-to-vive))
            (setq base-enable t)))
        (progn
          (when base
            (when base-enable (send self :switch-joy-to-ps3joy))
            (setq base-enable nil))
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
          (when base (send self :base-cb)))
        (t nil))
      (when head (send *ri* :angle-vector (send *pr2* :angle-vector) av-tm
                       :head-controller 0 :min-time 0.1 :scale av-scale))))
  (:main-loop (&key (head t) (base t))
    (while (ros::ok)
      (send *ti* :main-loop-step :head head :base base)
      (ros::spin-once)
      (ros::sleep))))

(defun pr2-vive-init ()
  (pr2-init)
  (setq *ti* (instance pr2-vive-interface :init)))
