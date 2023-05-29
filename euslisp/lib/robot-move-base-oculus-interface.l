;; -*- mode: lisp;-*-

(ros::roseus-add-msgs "geometry_msgs")

(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :robot-move-base-teleop-interface "package://eus_teleop/euslisp/lib/robot-move-base-teleop-interface.l")
(require :robot-oculus-interface "package://eus_teleop/euslisp/lib/robot-oculus-interface.l")


(provide :robot-move-base-oculus-interface)
