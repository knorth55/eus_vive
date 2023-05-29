;; -*- mode: lisp;-*-

(require :pr2-interface "package://pr2eus/pr2-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :robot-move-base-teleop-interface "package://eus_teleop/euslisp/lib/robot-move-base-teleop-interface.l")
(require :pr2-teleop-interface "package://eus_teleop/euslisp/lib/pr2-teleop-interface.l")
(require :robot-spacenav-interface "package://eus_teleop/euslisp/lib/robot-spacenav-interface.l")
(require :robot-move-base-spacenav-interface "package://eus_teleop/euslisp/lib/robot-move-base-spacenav-interface.l")


(defclass pr2-spacenav-interface
  :super robot-spacenav-interface
  :slots ())


(defmethod pr2-spacenav-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for spacenav
      (send self :set-val 'scale 1.0)
      (send self :set-val 'left-button-wait-count 10)
      (send self :set-val 'right-button-wait-count 10)
      (send self :set-val 'spacenav-joy-topic-name "/spacenav/joy"))))


(defun pr2-spacenav-init (&key (loop-enable t))
  (pr2-init)
  (make-pr2-irtviewer :no-window t)
  (make-pr2-camera-model :no-window t)
  (setq *ti* (instance pr2-spacenav-interface :init :loop-enable loop-enable))
  (send *ti* :ros-init))
