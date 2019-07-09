;; -*- mode: lisp;-*-

(load "package://pr2eus/pr2-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")

(defclass pr2-vive-interface
  :super robot-move-base-vive-interface 
  :slots ())


(defmethod pr2-vive-interface
  (:init ()
    (send-super :init)
    (send self :set-val 'robot *pr2*)
    (send self :set-val 'robot-interface *ri*)
    (send self :set-val 'irtviewer *irtviewer*)
    (send self :set-val 'scale 1.5)
    (send self :set-val 'av-tm 1000)
    (send self :set-val 'av-scale 8.0)
    (send self :set-val 'vx-thresh 0.3)
    (send self :set-val 'vy-thresh 0.3)
    (send self :set-val 'vw-thresh 0.3)
    (send self :set-val 'vx-scale 1.0)
    (send self :set-val 'vy-scale 1.0)
    (send self :set-val 'vw-scale 1.0)
    (send self :set-val 'arm-length 800)
    (send self :set-val 'head->shoulder-x-distance 200)
    (send self :set-val 'head->shoulder-z-distance 50))
  (:angle-vector (&rest args)
    (send* robot-interface :angle-vector args)))


(defun pr2-vive-init ()
  (pr2-init)
  (setq *ti* (instance pr2-vive-interface :init)))
