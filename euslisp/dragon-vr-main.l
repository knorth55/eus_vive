#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/dragon-spacenav-interface.l")


(defun spacenav-init (&key (loop-enable t))
  (dragon-spacenav-init :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ri* :wait-interpolation))


(defun init (&key (loop-enable t) (device-type :spacenav))
  (ros::roseus "dragon_vr_main" :anonymous nil)
  (cond
    ((eq device-type :spacenav)
     (spacenav-init :loop-enable loop-enable))
    (t nil))
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head nil) (safe-arm t) (mirror nil) (visualize t)
                  (loop-enable t) (device-type :spacenav))
  (init :loop-enable t :device-type device-type)
  (if (not loop-enable) (send *ti* :disable))
  (cond
    ((eq device-type :spacenav)
     (send *ti* :start)
     (unix::sleep 5)
     (send *ti* :takeoff)
     (unix::sleep 5)
     (send *ti* :main-loop :head head :torso nil :safe-arm safe-arm :mirror mirror
           :enable-button :right :gripper-button :left :visualize visualize))
    (t nil)))
