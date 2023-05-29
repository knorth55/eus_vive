;; -*- mode: lisp;-*-

(require :dragon-interface "package://dragon/euslisp/quad/dragon-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :dragon-teleop-interface "package://eus_teleop/euslisp/lib/dragon-teleop-interface.l")
(require :robot-spacenav-interface "package://eus_teleop/euslisp/lib/robot-spacenav-interface.l")


(defclass dragon-spacenav-interface
  :super robot-spacenav-interface
  :slots ())


(defmethod dragon-spacenav-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for spacenav
      (send self :set-val 'scale 1.0)
      (send self :set-val 'left-button-wait-count 10)
      (send self :set-val 'right-button-wait-count 10)
      (send self :set-val 'spacenav-joy-topic-name "/spacenav/joy"))))


(defun dragon-spacenav-init (&key (loop-enable t))
  (dragon-init)
  (make-dragon-irtviewer :no-window t)
  (make-dragon-camera-model :no-window t)
  (setq *ti* (instance dragon-spacenav-interface :init :loop-enable loop-enable))
  (send *ti* :ros-init))
