;; -*- mode: lisp;-*-
(load "package://pr2eus/pr2-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :pr2-vr-interface "package://eus_vive/euslisp/lib/pr2-vr-interface.l")
(require :robot-spacenav-interface "package://eus_vive/euslisp/lib/robot-spacenav-interface.l")


(defclass pr2-spacenav-interface
  :super robot-spacenav-interface
  :slots ())


(defmethod pr2-spacenav-interface
  (:init (&rest args)
    ;; for spacenav
    (send self :set-val 'spacenav-joy-topic-name "/spacenav/joy")
    (send-super* :init args)))


(defun pr2-spacenav-init (&key (loop-enable t))
  (pr2-init)
  (objects (list *pr2*))
  (setq *camera-model*
        (make-camera-from-param :pwidth 640 :pheight 640 :fx 400 :fy 400 :cx 319.5 :cy 319.5
                                :create-viewer t))
  (send *camera-model* :translate #f(1500 0 800))
  (send *camera-model* :rotate -1.57 :y :world)
  (send *camera-model* :rotate -1.57 :x :world)
  (setq *ti* (instance pr2-spacenav-interface :init :loop-enable loop-enable)))
