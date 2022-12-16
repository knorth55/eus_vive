;; -*- mode: lisp;-*-

(require :pr2-interface "package://pr2eus/pr2-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-move-base-vr-interface "package://eus_vive/euslisp/lib/robot-move-base-vr-interface.l")
(require :pr2-vr-interface "package://eus_vive/euslisp/lib/pr2-vr-interface.l")
(require :robot-tablis-interface "package://eus_vive/euslisp/lib/robot-tablis-interface.l")
(require :robot-move-base-tablis-interface "package://eus_vive/euslisp/lib/robot-move-base-tablis-interface.l")


(defclass pr2-tablis-interface
  :super robot-move-base-tablis-interface
  :slots ())


(defmethod pr2-tablis-interface
  (:init (&rest args)
    ;; for tablis
    (send self :set-val 'trigger-wait-count 5)
    (send self :set-val 'menu-wait-count 5)
    (send self :set-val 'trackpad-wait-count 5)
    (send self :set-val 'grip-wait-count 5)
    ;; for pr2 move base
    (send self :set-val 'vx-thresh 0.3)
    (send self :set-val 'vy-thresh 0.3)
    (send self :set-val 'vw-thresh 0.3)
    (send self :set-val 'vx-scale 1.0)
    (send self :set-val 'vy-scale 1.0)
    (send self :set-val 'vw-scale 1.0)
    (send-super* :init args)))


(defun pr2-tablis-init (&key (loop-enable t))
  (pr2-init)
  (objects (list *pr2*))
  (setq *camera-model*
        (if (string>= (car lisp-implementation-version) "9.28")
          (make-camera-from-param
            :pwidth 640 :pheight 640 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t :no-window t)
          (make-camera-from-param
            :pwidth 640 :pheight 640 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t)))
  (send *camera-model* :translate #f(1500 0 800))
  (send *camera-model* :rotate -1.57 :y :world)
  (send *camera-model* :rotate -1.57 :x :world)
  (setq *ti* (instance pr2-tablis-interface :init :loop-enable loop-enable)))
