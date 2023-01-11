;; -*- mode: lisp;-*-

(require :pr2-interface "package://pr2eus/pr2-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-move-base-vr-interface "package://eus_vive/euslisp/lib/robot-move-base-vr-interface.l")
(require :pr2-vr-interface "package://eus_vive/euslisp/lib/pr2-vr-interface.l")
(require :robot-spacenav-interface "package://eus_vive/euslisp/lib/robot-spacenav-interface.l")
(require :robot-move-base-spacenav-interface "package://eus_vive/euslisp/lib/robot-move-base-spacenav-interface.l")


(defclass pr2-spacenav-interface
  :super robot-spacenav-interface
  :slots ())


(defmethod pr2-spacenav-interface
  (:init (&rest args)
    ;; for spacenav
    (send self :set-val 'scale 1.0)
    (send self :set-val 'left-button-wait-count 10)
    (send self :set-val 'right-button-wait-count 10)
    (send self :set-val 'spacenav-joy-topic-name "/spacenav/joy")
    (send-super* :init args)))


(defun pr2-spacenav-init (&key (loop-enable t))
  (pr2-init)
  (make-pr2-irtviewer :no-window t)
  (make-pr2-camera-model :no-window t)
  (setq *ti* (instance pr2-spacenav-interface :init :loop-enable loop-enable)))
