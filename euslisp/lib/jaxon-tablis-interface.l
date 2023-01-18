;; -*- mode: lisp;-*-

(require :jaxon-interface "package://hrpsys_ros_bridge_tutorials/euslisp/jaxon-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :robot-move-base-teleop-interface "package://eus_teleop/euslisp/lib/robot-move-base-teleop-interface.l")
(require :jaxon-teleop-interface "package://eus_teleop/euslisp/lib/jaxon-teleop-interface.l")
(require :robot-vive-interface "package://eus_teleop/euslisp/lib/robot-vive-interface.l")
(require :robot-move-base-vive-interface "package://eus_teleop/euslisp/lib/robot-move-base-vive-interface.l")
(require :robot-tablis-interface "package://eus_teleop/euslisp/lib/robot-tablis-interface.l")
(require :robot-move-base-tablis-interface "package://eus_teleop/euslisp/lib/robot-move-base-tablis-interface.l")


(defclass jaxon-tablis-interface
  :super robot-tablis-interface
  :slots ())


(defmethod jaxon-tablis-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for tablis
      (send self :set-val 'scale 1.0)
      (send self :set-val 'trigger-wait-count 5)
      (send self :set-val 'menu-wait-count 5)
      (send self :set-val 'trackpad-wait-count 5)
      (send self :set-val 'grip-wait-count 5)
      (send self :set-val 'larm-tablis-pose-topic-name "/master_larm_pose_orig")
      (send self :set-val 'rarm-tablis-pose-topic-name "/master_rarm_pose_orig")
      (send self :set-val 'lleg-tablis-pose-topic-name "/master_lleg_pose_orig")
      (send self :set-val 'rleg-tablis-pose-topic-name "/master_rleg_pose_orig")
      (send self :set-val 'larm-command-pose-topic-name "/master_larm_pose")
      (send self :set-val 'rarm-command-pose-topic-name "/master_rarm_pose")
      (send self :set-val 'lleg-command-pose-topic-name "/master_lleg_pose")
      (send self :set-val 'rleg-command-pose-topic-name "/master_rleg_pose")
      ))
  )


(defun jaxon-tablis-init (&key (loop-enable t))
  (jaxon-init)
  (make-jaxon-irtviewer :no-window t)
  (make-jaxon-camera-model :no-window t)
  (setq *ti* (instance jaxon-tablis-interface :init :loop-enable loop-enable))
  (send *ti* :ros-init))
