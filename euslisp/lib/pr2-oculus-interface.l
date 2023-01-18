;; -*- mode: lisp;-*-

(require :pr2-interface "package://pr2eus/pr2-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :robot-move-base-teleop-interface "package://eus_teleop/euslisp/lib/robot-move-base-teleop-interface.l")
(require :pr2-teleop-interface "package://eus_teleop/euslisp/lib/pr2-teleop-interface.l")
(require :robot-oculus-interface "package://eus_teleop/euslisp/lib/robot-oculus-interface.l")


(defclass pr2-oculus-interface
  :super robot-oculus-interface
  :slots ())


(defmethod pr2-oculus-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for oculus
      (send self :set-val 'scale 1.5)
      (send self :set-val 'hmd-pose-topic-name "/oculus/hmd/pose_stamped")
      (send self :set-val 'left-controller-pose-topic-name "/oculus/left_controller/pose_stamped")
      (send self :set-val 'right-controller-pose-topic-name "/oculus/right_controller/pose_stamped"))))


(defun pr2-oculus-init (&key (loop-enable t))
  (pr2-init)
  (make-pr2-irtviewer :no-window t)
  (make-pr2-camera-model :no-window t)
  (setq *ti* (instance pr2-oculus-interface :init :loop-enable loop-enable))
  (send *ti* :ros-init))
