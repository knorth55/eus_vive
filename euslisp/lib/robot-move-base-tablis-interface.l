;; -*- mode: lisp;-*-

(ros::roseus-add-msgs "geometry_msgs")

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-move-base-vr-interface "package://eus_vive/euslisp/lib/robot-move-base-vr-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")
(require :robot-move-base-vive-interface "package://eus_vive/euslisp/lib/robot-move-base-vive-interface.l")


(defclass robot-move-base-tablis-interface
  :super robot-move-base-vive-interface
  :slots ())


(provide :robot-move-base-tablis-interface)
