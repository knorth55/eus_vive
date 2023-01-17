;; -*- mode: lisp;-*-

(ros::roseus-add-msgs "geometry_msgs")

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-move-base-vr-interface "package://eus_vive/euslisp/lib/robot-move-base-vr-interface.l")
(require :robot-oculus-interface "package://eus_vive/euslisp/lib/robot-oculus-interface.l")


(provide :robot-move-base-oculus-interface)
