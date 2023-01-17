;; -*- mode: lisp;-*-

(ros::roseus-add-msgs "geometry_msgs")

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-move-base-vr-interface "package://eus_vive/euslisp/lib/robot-move-base-vr-interface.l")
(require :robot-spacenav-interface "package://eus_vive/euslisp/lib/robot-spacenav-interface.l")


(provide :robot-move-base-spacenav-interface)
