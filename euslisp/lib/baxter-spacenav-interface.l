;; -*- mode: lisp;-*-
(ros::load-ros-manifest "baxter_core_msgs")

(require :baxter-interface "package://eus_vive/euslisp/lib/baxter-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :baxter-vr-interface "package://eus_vive/euslisp/lib/baxter-vr-interface.l")
(require :robot-spacenav-interface "package://eus_vive/euslisp/lib/robot-spacenav-interface.l")


(defclass baxter-spacenav-interface
  :super robot-spacenav-interface
  :slots (larm-thumb-open
          rarm-thumb-open))


(defmethod baxter-spacenav-interface
  (:init (&rest args)
    ;; for spacenav
    (send self :set-val 'left-button-wait-count 10)
    (send self :set-val 'right-button-wait-count 10)
    (send self :set-val 'spacenav-joy-topic-name "/spacenav/joy")
    (send-super* :init args)
    ;; override to control rarm
    (send self :set-val 'control-arm :rarm))
  (:arm-motion-cb (&rest args &key (mirror nil) (thumb-rotate-button nil) &allow-other-keys)
    (send-super* :arm-motion-cb :mirror mirror :thumb-rotate-button thumb-rotate-button args)))


(defun baxter-spacenav-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
  (eus_vive::baxter-init :lgripper lgripper :rgripper rgripper)
  (objects (list *baxter*))
  (setq *camera-model*
        (if (string>= (car lisp-implementation-version) "9.28")
          (make-camera-from-param
            :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t :no-window t)
          (make-camera-from-param
            :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
            :name "camera" :create-viewer t)))
  (send *camera-model* :translate #f(1500 0 600))
  (send *camera-model* :rotate -pi/2 :y :world)
  (send *camera-model* :rotate -pi/2 :x :world)
  (send *camera-model* :rotate -0.30 :y :world)
  (send *irtviewer* :change-background (float-vector 1 1 1))
  (send *irtviewer* :draw-floor 100)
  (send *irtviewer* :floor-color #f(0 0 0))
  (setq *background-cube* (make-cube 10 6000 6000))
  (send *background-cube* :set-color #f(1 1 1))
  (send *background-cube* :translate #f(-1000 0 0))
  (setq *ti* (instance baxter-spacenav-interface :init :loop-enable loop-enable
                       :lgripper lgripper :rgripper rgripper)))
