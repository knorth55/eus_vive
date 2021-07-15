#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/baxter-vive-interface.l")
(load "package://eus_vive/euslisp/lib/baxter-oculus-interface.l")
(load "package://eus_vive/euslisp/lib/baxter-spacenav-interface.l")


(defun vive-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
  (baxter-vive-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ri* :wait-interpolation)
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm))


(defun oculus-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
  (baxter-oculus-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ri* :wait-interpolation))


(defun spacenav-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
  (baxter-spacenav-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ri* :wait-interpolation))


(defun init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t) (device-type :vive))
  (ros::roseus "baxter_vr_main" :anonymous nil)
  (cond
    ((eq device-type :vive)
     (vive-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable))
    ((eq device-type :oculus)
     (oculus-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable))
    ((eq device-type :spacenav)
     (spacenav-init :lgripper lgripper :rgripper rgripper :loop-enable loop-enable))
    (t nil))
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head nil) (safe-arm t) (mirror nil) (visualize t)
                  (lgripper :parallel) (rgripper :parallel) (loop-enable t) (device-type :vive))
  (init :lgripper lgripper :rgripper rgripper :loop-enable t :device-type device-type)
  (send *ri* :nod)
  (if (not loop-enable) (send *ti* :disable))
  (cond
    ((eq device-type :vive)
     (send *ti* :main-loop :head head :torso nil :safe-arm safe-arm :mirror mirror
           :enable-button :menu :gripper-button :trigger :visualize visualize))
    ((eq device-type :oculus)
     (send *ti* :main-loop :head head :torso nil :safe-arm safe-arm :mirror mirror
           :enable-button :menu :gripper-button :trigger :visualize visualize))
    ((eq device-type :spacenav)
     (send *ti* :main-loop :head head :torso nil :safe-arm safe-arm :mirror mirror
           :enable-button :right :gripper-button :left :visualize visualize))
    (t nil)))
