;; -*- mode: lisp;-*-

(ros::load-ros-manifest "sensor_msgs")

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(defclass robot-spacenav-interface
  :super robot-vr-interface
  :slots (spacenav-joy-topic-name
          ))


(defmethod robot-spacenav-interface
  (:init (&rest args)
    ;; for spacenav
    (ros::subscribe spacenav-joy-topic-name
                    sensor_msgs::Joy #'send self :spacenav-joy-cb)
    (send-super* :init args))
  (:enable ()
    (send self :set-arm-val :larm :enable t)
    (send self :set-arm-val :rarm :enable t))
  ;; spsacenav joy callbacks
  (:spacenav-joy-cb (msg)
    (send self :spacenav-joy-axes-cb (send msg :axes))
    (send self :spacenav-joy-buttons-cb (send msg :buttons)))
  ;; move from current coords
  ;; TODO (knorth55): implement :spacenav-joy-axes-cb
  (:spacenav-joy-axes-cb (axes)
    )
  ;; left: grasp, right: change arm
  ;; TODO (knorth55): implement :spacenav-joy-buttons-cb
  (:spacenav-joy-buttons-cb (buttons)
    )
  ;; :get-target-coords
  ;; TODO (knorth55): implement :get-target-coords
  (:get-target-coords (arm &key (head t) (mirror nil))
    ))


(provide :robot-spacenav-interface)
