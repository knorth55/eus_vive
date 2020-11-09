#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/baxter-vive-interface.l")


(defun vive-init (&key (lgripper :parallel) (rgripper parallel) (loop-enable t))
  (baxter-vive-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ri* :wait-interpolation)
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm))


(defun oculus-init (&key (lgripper :parallel) (rgripper parallel) (loop-enable t))
  (baxter-oculus-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ri* :wait-interpolation))


(defun init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t) (device-type :vive))
  (ros::roseus "baxter_vr_main" :anonymous nil)
  (if (eq device-type :oculus)
    (oculus-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable)
    (vive-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable))
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head nil) (safe-arm t) (mirror nil) (visualize t)
                  (lgripper :parallel) (rgripper :parallel) (loop-enable t) (device-type :vive))
  (init :lgripper lgripper :rgripper rgripper :loop-enable t :device-type device-type)
  ; (if (not head)
  ;   (while (not (send *ti* :calibrate))
  ;     (ros::spin-once)))
  (send *ri* :nod)
  (if (not loop-enable) (send *ti* :disable))
  (send *ti* :main-loop :head head :torso nil
        :safe-arm safe-arm :mirror mirror
        :enable-button :menu :gripper-button :trigger :visualize visualize))
