#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/pr2-vive-interface.l")


(defun init ()
  (ros::roseus "vive_pr2eus")
  (pr2-vive-init)
  (send *ri* :angle-vector (send *pr2* :reset-pose))
  (send *ri* :stop-grasp :arms)
  (send *ri* :wait-interpolation)
  (send *ri* :clear-costmap)
  (objects (list *pr2*))
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm))


(defun main (&key (head t) (base t) (unsafe t) (visualize t))
  (init)
  (send *ti* :calib-vive :rarm :scale t)
  (send *ti* :main-loop :head head :base base
        :unsafe unsafe :visualize visualize))
