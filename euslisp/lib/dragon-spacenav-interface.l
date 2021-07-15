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
  (objects (list *dragon*))
  (setq *camera-model*
        (make-camera-from-param :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
                                :name "camera" :create-viewer t))
  (send *camera-model* :translate #f(1500 0 0))
  (send *camera-model* :rotate -pi/2 :y :world)
  (send *camera-model* :rotate -pi/2 :x :world)
  (send *irtviewer* :change-background (float-vector 1 1 1))
  (send *irtviewer* :draw-floor 100)
  (send *irtviewer* :floor-color #f(0 0 0))
  (setq *background-cube* (make-cube 10 6000 6000))
  (send *background-cube* :set-color #f(1 1 1))
  (send *background-cube* :translate #f(-1000 0 0))
  (setq *ti* (instance dragon-spacenav-interface :init :loop-enable loop-enable)))
