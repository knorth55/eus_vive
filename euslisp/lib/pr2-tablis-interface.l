;; -*- mode: lisp;-*-

(require :pr2-interface "package://pr2eus/pr2-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :robot-move-base-teleop-interface "package://eus_teleop/euslisp/lib/robot-move-base-teleop-interface.l")
(require :pr2-teleop-interface "package://eus_teleop/euslisp/lib/pr2-teleop-interface.l")
(require :robot-vive-interface "package://eus_teleop/euslisp/lib/robot-vive-interface.l")
(require :robot-move-base-vive-interface "package://eus_teleop/euslisp/lib/robot-move-base-vive-interface.l")
(require :robot-tablis-interface "package://eus_teleop/euslisp/lib/robot-tablis-interface.l")
(require :robot-move-base-tablis-interface "package://eus_teleop/euslisp/lib/robot-move-base-tablis-interface.l")


(defclass pr2-tablis-interface
  :super robot-tablis-interface
  :slots ())


(defmethod pr2-tablis-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for tablis
      (send self :set-val 'scale 1.0)
      (send self :set-val 'trigger-wait-count 5)
      (send self :set-val 'menu-wait-count 5)
      (send self :set-val 'trackpad-wait-count 5)
      (send self :set-val 'grip-wait-count 5)
      (send self :set-val 'larm-tablis-pose-topic-name "/master_larm_pose")
      (send self :set-val 'rarm-tablis-pose-topic-name "/master_rarm_pose"))))


(defun pr2-tablis-init (&key (loop-enable t))
  (pr2-init)
  (make-pr2-irtviewer :no-window t)
  (make-pr2-camera-model :no-window t)
  (setq *ti* (instance pr2-tablis-interface :init :loop-enable loop-enable))
  (send *ti* :ros-init))
