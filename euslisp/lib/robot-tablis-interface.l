;; -*- mode: lisp;-*-

(ros::roseus-add-msgs "geometry_msgs")

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")


(defclass robot-tablis-interface
  :super robot-vive-interface
  :slots (left-tablis-pose-topic-name
          larm-tablis-coords
          larm-ref-tablis-coords
          larm-ref-end-coords
          right-tablis-pose-topic-name
          rarm-tablis-coords
          rarm-ref-tablis-coords
          rarm-ref-end-coords))


(defmethod robot-tablis-interface
  (:init (&rest args)
    (ros::subscribe left-tablis-pose-topic-name geometry_msgs::PoseStamped
                    #'send self :tablis-pose-stamped-cb :larm)
    (ros::subscribe right-tablis-pose-topic-name geometry_msgs::PoseStamped
                    #'send self :tablis-pose-stamped-cb :rarm)
    (send-super* :init args))
  (:tablis-pose-stamped-cb (arm msg)
    (send self :set-arm-val arm :tablis-coords (ros::tf-pose-stamped->coords msg)))
  (:get-target-coords (arm &key (head t) (mirror nil))
    (let* ((target-arm (if mirror (send self :get-opposite-arm arm) arm))
           (tablis-coords
             (if (send self :get-arm-val target-arm :tablis-coords)
               (send (send self :get-arm-val target-arm :tablis-coords) :copy-worldcoords)))
           (ref-tablis-coords
             (if (send self :get-arm-val target-arm :ref-tablis-coords)
               (send (send self :get-arm-val target-arm :ref-tablis-coords) :copy-worldcoords)))
           (ref-end-coords
             (if (send self :get-arm-val target-arm :ref-end-coords)
               (send (send self :get-arm-val target-arm :ref-end-coords) :copy-worldcoords)))
           target-coords)
      (if (or (null ref-tablis-coords) (null ref-end-coords))
        (progn
          (send self :set-reference-coords target-arm :update-robot-model t)
          (setq ref-tablis-coords
                (send (send self :get-arm-val target-arm :ref-tablis-coords) :copy-worldcoords))
          (setq ref-end-coords
                (send (send self :get-arm-val target-arm :ref-end-coords) :copy-worldcoords))))
      (if tablis-coords
        (let* ((ref-end-coords-pos (send ref-end-coords :worldpos))
               (ref-end-coords-rot (send ref-end-coords :worldrot))
               (diff-tablis-coords
                 (send ref-tablis-coords :transformation tablis-coords :world))
               (diff-tablis-pos
                 (v- (send tablis-coords :worldpos)
                     (send ref-tablis-coords :worldpos)))
               (diff-tablis-rot (send diff-tablis-coords :worldrot))
               (diff-target-pos
                 (float-vector (* scale (elt diff-tablis-pos 0))
                               (* scale (elt diff-tablis-pos 1))
                               (* scale (elt diff-tablis-pos 2))))
               (target-pos (v+ ref-end-coords-pos diff-target-pos))
               (target-rot
                 (send (send (make-coords :rot ref-end-coords-rot) :transform
                             (make-coords :rot diff-tablis-rot) :world)
                       :worldrot)))
          (if mirror
            (progn
              (setq target-pos (send self :get-mirror-pos target-pos))
              (setq target-rot (send self :get-mirror-rot target-rot))))
          (setq target-coords
                (make-coords :pos target-pos
                             :rot target-rot))))
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
    (if (send self :get-arm-val arm :tablis-coords)
      (send self :set-arm-val arm :ref-tablis-coords
            (send (send self :get-arm-val arm :tablis-coords) :copy-worldcoords)))
    (if (send robot arm :end-coords)
      (send self :set-arm-val arm :ref-end-coords
            (send (send robot arm :end-coords) :copy-worldcoords)))
    t)
  )
