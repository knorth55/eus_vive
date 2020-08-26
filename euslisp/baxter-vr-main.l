#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/baxter-vive-interface.l")


(defun vive-init (&key (lgripper :parallel) (rgripper parallel) (loop-enable t))
  (baxter-vive-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable)
  (send *ri* :stop-grasp :arms :wait nil)
  (send *ri* :angle-vector-raw (send *baxter* :reset-teleop-pose) 5000)
  (send *ri* :wait-interpolation)
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm))


(defun oculus-init (&key (lgripper :parallel) (rgripper parallel) (loop-enable t))
  (baxter-oculus-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable)
  (send *ri* :stop-grasp :arms :wait nil)
  (send *ri* :angle-vector-raw (send *baxter* :reset-teleop-pose) 5000)
  (send *ri* :wait-interpolation))


(defun init (&key (lgripper :parallel) (rgripper parallel) (loop-enable t) (device-type :vive))
  (ros::roseus "baxter_vr_main" :anonymous nil)
  (if (eq device-type :oculus)
    (oculus-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable)
    (vive-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable))
  ;; overwrite s0, e0 joint limit
  ;; do not rotate s0, e0 joint and stay arm in front of the robot
  (send *baxter* :left_s0 :max-angle 30)
  (send *baxter* :left_e0 :max-angle 30)
  (send *baxter* :right_s0 :min-angle -30)
  (send *baxter* :right_e0 :min-angle -30)
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head nil) (safe-arm t) (mirror nil) (visualize t)
                  (lgripper :parallel) (rgripper parallel) (loop-enable t) (device-type :vive))
  (init :lgripper lgripper :rgripper rgripper :loop-enable t :device-type device-type)
  (unless head
    (while (not (send *ti* :calibrate))
      (ros::spin-once)))
  (send *ri* :nod)
  (unless loop-enable (send *ti* :disable))
  (send *ti* :main-loop :head head :torso nil
        :safe-arm safe-arm :mirror mirror
        :enable-button :menu :gripper-button :trigger :visualize visualize))
