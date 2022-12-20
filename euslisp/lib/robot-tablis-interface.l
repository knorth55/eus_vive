;; -*- mode: lisp;-*-

(ros::roseus-add-msgs "geometry_msgs")

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")


(defclass robot-tablis-interface
  :super robot-vive-interface
  :slots (larm-tablis-coords
          larm-ref-tablis-coords
          larm-ref-end-coords
          rarm-tablis-coords
          rarm-ref-tablis-coords
          rarm-ref-end-coords))


(defmethod robot-tablis-interface
  (:init (&rest args)
    (ros::subscribe "/master_larm_pose" geometry_msgs::PoseStamped
                    #'send self :tablis-pose-stamped-cb :larm)
    (ros::subscribe "/master_rarm_pose" geometry_msgs::PoseStamped
                    #'send self :tablis-pose-stamped-cb :rarm)
    (send-super* :init args))
  (:tablis-pose-stamped-cb (arm msg)
    (send self :set-arm-val arm :tablis-coords (ros::tf-pose-stamped->coords msg)))
  (:get-target-coords (arm &key (head t) (mirror nil))
    (let* ((target-arm (if mirror (send self :get-opposite-arm arm) arm))
           (tablis-coords
             (send self :get-arm-val target-arm :tablis-coords))
           (ref-tablis-coords
             (send self :get-arm-val target-arm :ref-tablis-coords))
           (ref-end-coords
             (send self :get-arm-val target-arm :ref-end-coords))
           target-coords)
      (if (or (null ref-tablis-coords) (null ref-end-coords))
        (progn
          (send self :set-reference-coords target-arm :update-robot-model t)
          (setq ref-tablis-coords
                (send self :get-arm-val target-arm :ref-tablis-coords))
          (setq ref-end-coords
                (send self :get-arm-val target-arm :ref-end-coords))))
      (if tablis-coords
        (progn
          (setq target-coords (send ref-end-coords :copy-worldcoords))
          (setq diff-tablis-coords
                (send ref-tablis-coords :transformation tablis-coords :world))
          (send target-coords :transform diff-tablis-coords :world)))
      target-coords))
  (:calib-controller (&optional (arm :rarm))
    (if (equal arm :arms)
      (progn
        (send self :set-reference-coords :larm :update-robot-model t)
        (send self :set-reference-coords :rarm :update-robot-model nil))
      (send self :set-reference-coords arm :update-robot-model t))
    t)
  (:set-reference-coords (arm &key (update-robot-model t))
    (if update-robot-model (send self :update-robot-model))
    (send self :set-arm-val arm :ref-tablis-coords
          (send self :get-arm-val arm :tablis-coords))
    (send self :set-arm-val arm :ref-end-coords
          (send (send robot arm :end-coords) :copy-worldcoords))
    t)
  )
