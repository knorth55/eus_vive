#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/baxter-vive-interface.l")


(defun init ()
  (ros::roseus "baxter_vive_main" :anonymous nil)
  (baxter-vive-init)
  ;; overwrite s0, e0 joint limit
  ;; do not rotate s0, e0 joint and stay arm in front of the robot
  (send *baxter* :left_s0 :max-angle 30)
  (send *baxter* :left_e0 :max-angle 30)
  (send *baxter* :right_s0 :min-angle -30)
  (send *baxter* :right_e0 :min-angle -30)
  (send *ri* :angle-vector-raw (send *baxter* :untuck-pose) 5000)
  (send *ri* :stop-grasp :arms :wait nil)
  (send *ri* :wait-interpolation)
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm)
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head nil) (mirror nil) (visualize t))
  (init)
  (while (not (send *ti* :calib-vive :rarm)))
  (send *ti* :main-loop :head head :torso nil
        :mirror mirror :enable-button :menu :visualize visualize))
