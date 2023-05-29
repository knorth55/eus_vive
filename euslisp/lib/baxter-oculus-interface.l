;; -*- mode: lisp;-*-
(ros::load-ros-manifest "baxter_core_msgs")

(require :baxter-interface "package://eus_teleop/euslisp/lib/baxter-interface.l")
(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :baxter-teleop-interface "package://eus_teleop/euslisp/lib/baxter-teleop-interface.l")
(require :robot-oculus-interface "package://eus_teleop/euslisp/lib/robot-oculus-interface.l")


(defclass baxter-oculus-interface
  :super robot-oculus-interface
  :slots (larm-thumb-open
          rarm-thumb-open))


(defmethod baxter-oculus-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for oculus
      (send self :set-val 'scale 3.0)
      (send self :set-val 'hmd-pose-topic-name "/oculus/hmd/pose_stamped")
      (send self :set-val 'left-controller-pose-topic-name "/oculus/left_controller/pose_stamped")
      (send self :set-val 'right-controller-pose-topic-name "/oculus/right_controller/pose_stamped"))))


(defun baxter-oculus-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
  (eus_teleop::baxter-init :lgripper lgripper :rgripper rgripper :limit-in-front t)
  (make-baxter-irtviewer :no-window t)
  (make-baxter-camera-model :no-window t)
  (setq *ti* (instance baxter-oculus-interface :init :loop-enable loop-enable
                       :lgripper lgripper :rgripper rgripper))
  (send *ti* :ros-init))
