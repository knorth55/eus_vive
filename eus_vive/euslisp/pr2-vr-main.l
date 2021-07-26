#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/pr2-vive-interface.l")
(load "package://eus_vive/euslisp/lib/pr2-oculus-interface.l")
(load "package://eus_vive/euslisp/lib/pr2-spacenav-interface.l")


(defun vive-init (&key (loop-enable t))
  (pr2-vive-init :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ti* :reset-torso :wait nil)
  (send *ri* :wait-interpolation)
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm))


(defun oculus-init (&key (loop-enable t))
  (pr2-oculus-init :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ti* :reset-torso :wait nil)
  (send *ri* :wait-interpolation))


(defun spacenav-init (&key (loop-enable t))
  (pr2-spacenav-init :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ti* :reset-torso :wait nil)
  (send *ri* :wait-interpolation))


(defun init (&key (loop-enable t) (device-type :vive))
  (ros::roseus "pr2_vr_main" :anonymous nil)
  (cond
    ((eq device-type :vive) (vive-init :loop-enable loop-enable))
    ((eq device-type :oculus) (oculus-init :loop-enable loop-enable))
    ((eq device-type :spacenav) (spacenav-init :loop-enable loop-enable))
    (t nil))
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head t) (torso t) (base t) (safe-arm t) (safe-base nil) (mirror nil)
                  (visualize t) (loop-enable t) (device-type :vive))
  (init :loop-enable t :device-type device-type)
  (if (not loop-enable) (send *ti* :disable))
  (cond
    ((eq device-type :vive)
     (send *ti* :main-loop :head head :torso torso :base base
           :safe-arm safe-arm :safe-base safe-base :mirror mirror
           :enable-button :menu :gripper-button :trigger :visualize visualize))
    ((eq device-type :oculus)
     (send *ti* :main-loop :head head :torso torso :safe-arm safe-arm :mirror mirror
           :enable-button :menu :gripper-button :trigger :visualize visualize))
    ((eq device-type :spacenav)
     (send *ti* :main-loop :head head :torso torso :safe-arm safe-arm :mirror mirror
           :enable-button :right :gripper-button :left :visualize visualize))
    (t nil)))
