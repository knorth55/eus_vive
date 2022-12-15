;; -*- mode: lisp;-*-

(ros::roseus-add-msgs "geometry_msgs")

(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")


(defclass robot-tablis-interface
  ;; TODO: mulitple inheritance for move base robot
  :super robot-move-base-vive-interface
  ; :super robot-vive-interface
  :slots (larm-target-pose
          larm-prev-target-pose
          rarm-target-pose
          rarm-prev-target-pose))


(defmethod robot-tablis-interface
  (:init (&rest args)
    (send-super* :init args)
    (ros::subscribe "/master_larm_pose" geometry_msgs::PoseStamped
                    #'send self :tablis-pose-stamped-cb :larm)
    (ros::subscribe "/master_rarm_pose" geometry_msgs::PoseStamped
                    #'send self :tablis-pose-stamped-cb :rarm))
  (:tablis-pose-stamped-cb (arm msg)
    (send self :set-arm-val arm :prev-target-pose
          (send self :get-arm-val arm :target-pose))
    (send self :set-arm-val arm :target-pose msg))
  (:get-target-coords (arm &key (head t) (mirror nil))
    (let ((target-pose
            (send self :get-arm-val
                  (if mirror (send self :get-opposite-arm arm) arm)
                  :target-pose))
          target-coords)
      (if target-pose
        (progn
          (setq target-coords (ros::tf-pose-stamped->coords (target-pose)))
          ;; TODO: do something on target-coords
          ))
      target-coords))
  (:calib-controller (&rest args)
    (ros::ros-warn ":calib-controller is disabled."))
  )
