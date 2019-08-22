#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/baxter-vive-interface.l")


(defun init (&key (loop-enable t))
  (ros::roseus "baxter_vive_main" :anonymous nil)
  (baxter-vive-init :loop-enable loop-enable)
  ;; overwrite s0, e0 joint limit
  ;; do not rotate s0, e0 joint and stay arm in front of the robot
  (send *baxter* :left_s0 :max-angle 30)
  (send *baxter* :left_e0 :max-angle 30)
  (send *baxter* :right_s0 :min-angle -30)
  (send *baxter* :right_e0 :min-angle -30)
  (send *ri* :stop-grasp :arms :wait nil)
  (send *ri* :angle-vector-raw (send *baxter* :reset-teleop-pose) 5000)
  (send *ri* :wait-interpolation)
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm)
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head nil) (safe-arm t) (mirror nil) (visualize t) (loop-enable t))
  (init :loop-enable t)
  (unless head
    (while (not (send *ti* :calibrate :rarm))
      (ros::spin-once)))
  (send *ri* :nod)
  (unless loop-enable (send *ti* :disable))
  (send *ti* :main-loop :head head :torso nil
        :safe-arm safe-arm :mirror mirror :enable-button :menu :visualize visualize))
