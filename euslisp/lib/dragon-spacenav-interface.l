;; -*- mode: lisp;-*-

(require :dragon-interface "package://dragon/euslisp/quad/dragon-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :dragon-vr-interface "package://eus_vive/euslisp/lib/dragon-vr-interface.l")
(require :robot-spacenav-interface "package://eus_vive/euslisp/lib/robot-spacenav-interface.l")


(defclass dragon-spacenav-interface
  :super robot-spacenav-interface
  :slots ())


(defmethod dragon-spacenav-interface
  (:init (&rest args)
    ;; for spacenav
    (send self :set-val 'left-button-wait-count 10)
    (send self :set-val 'right-button-wait-count 10)
    (send self :set-val 'spacenav-joy-topic-name "/spacenav/joy")
    (send-super* :init args)))


(defun dragon-spacenav-init (&key (loop-enable t))
  (dragon-init)
  (make-dragon-irtviewer :no-window t)
  (make-dragon-camera-model :no-window t)
  (setq *ti* (instance dragon-spacenav-interface :init :loop-enable loop-enable)))
