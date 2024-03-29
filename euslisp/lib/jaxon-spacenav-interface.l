;; -*- mode: lisp;-*-

(require :jaxon-interface "package://hrpsys_ros_bridge_tutorials/euslisp/jaxon-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-move-base-vr-interface "package://eus_vive/euslisp/lib/robot-move-base-vr-interface.l")
(require :jaxon-vr-interface "package://eus_vive/euslisp/lib/jaxon-vr-interface.l")
(require :robot-spacenav-interface "package://eus_vive/euslisp/lib/robot-spacenav-interface.l")
(require :robot-move-base-spacenav-interface "package://eus_vive/euslisp/lib/robot-move-base-spacenav-interface.l")


(defclass jaxon-spacenav-interface
  :super robot-spacenav-interface
  :slots ())


(defmethod jaxon-spacenav-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for spacenav
      (send self :set-val 'scale 1.0)
      (send self :set-val 'left-button-wait-count 10)
      (send self :set-val 'right-button-wait-count 10)
      (send self :set-val 'spacenav-joy-topic-name "/spacenav/joy"))))


(defun jaxon-spacenav-init (&key (loop-enable t))
  (jaxon-init)
  (make-jaxon-irtviewer :no-window t)
  (make-jaxon-camera-model :no-window t)
  (setq *ti* (instance jaxon-spacenav-interface :init :loop-enable loop-enable))
  (send *ti* :ros-init))
