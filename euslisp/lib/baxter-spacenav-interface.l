;; -*- mode: lisp;-*-
(ros::load-ros-manifest "baxter_core_msgs")

(require :baxter-interface "package://eus_teleop/euslisp/lib/baxter-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :baxter-teleop-interface "package://eus_teleop/euslisp/lib/baxter-teleop-interface.l")
(require :robot-spacenav-interface "package://eus_teleop/euslisp/lib/robot-spacenav-interface.l")


(defclass baxter-spacenav-interface
  :super robot-spacenav-interface
  :slots (larm-thumb-open
          rarm-thumb-open))


(defmethod baxter-spacenav-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for spacenav
      (send self :set-val 'scale 1.0)
      (send self :set-val 'left-button-wait-count 10)
      (send self :set-val 'right-button-wait-count 10)
      (send self :set-val 'spacenav-joy-topic-name "/spacenav/joy")
      ;; override to control rarm
      (send self :set-val 'control-arm :rarm)))
  (:arm-motion-cb (&rest args &key (mirror nil) (thumb-rotate-button nil) &allow-other-keys)
    (send-super* :arm-motion-cb :mirror mirror :thumb-rotate-button thumb-rotate-button args)))


(defun baxter-spacenav-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
  (eus_teleop::baxter-init :lgripper lgripper :rgripper rgripper)
  (make-baxter-irtviewer :no-window t)
  (make-baxter-camera-model :no-window t)
  (setq *ti* (instance baxter-spacenav-interface :init :loop-enable loop-enable
                       :lgripper lgripper :rgripper rgripper))
  (send *ti* :ros-init))
