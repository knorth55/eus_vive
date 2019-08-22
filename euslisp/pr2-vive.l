#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/pr2-vive-interface.l")


(defun init (&key (loop-enable t))
  (ros::roseus "pr2_vive_main" :anonymous nil)
  (pr2-vive-init :loop-enable loop-enable)
  (send *ri* :angle-vector (send *pr2* :reset-pose))
  (send *ri* :stop-grasp :arms :wait nil)
  (send *ri* :wait-interpolation)
  (send *ri* :clear-costmap)
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm)
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head t) (torso t) (base t) (safe-arm t) (safe-base nil) (mirror nil)
                  (visualize t) (loop-enable t))
  (init :loop-enable t)
  (unless head
    (while (not (send *ti* :calibrate :rarm))
      (ros::spin-once)))
  (unless loop-enable (send *ti* :disable))
  (send *ti* :main-loop :head head :torso torso :base base
        :safe-arm safe-arm :safe-base safe-base :mirror mirror
        :enable-button :menu :visualize visualize))
