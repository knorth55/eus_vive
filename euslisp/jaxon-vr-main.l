#!/usr/bin/env roseus

(require :jaxon-spacenav-interface "package://eus_vive/euslisp/lib/jaxon-spacenav-interface.l")
(require :jaxon-tablis-interface "package://eus_vive/euslisp/lib/jaxon-tablis-interface.l")


(defun spacenav-init (&key (loop-enable t))
  (jaxon-spacenav-init :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ri* :wait-interpolation))


(defun tablis-init (&key (loop-enable t))
  (jaxon-tablis-init :loop-enable loop-enable)
  (send *ti* :reset-arm :larm :wait nil)
  (send *ti* :reset-arm :rarm :wait nil)
  (send *ri* :wait-interpolation)
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm))


(defun init (&key (loop-enable t) (device-type :spacenav))
  (ros::roseus "jaxon_vr_main" :anonymous nil)
  (cond
    ((eq device-type :spacenav) (spacenav-init :loop-enable loop-enable))
    ((eq device-type :tablis) (tablis-init :loop-enable loop-enable))
    (t nil))
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head nil) (safe-arm t) (mirror nil) (visualize t)
                  (loop-enable t) (device-type :spacenav))
  (init :loop-enable t :device-type device-type)
  (if (not loop-enable) (send *ti* :disable))
  (cond
    ((eq device-type :spacenav)
     (send *ti* :main-loop :head head :torso nil :safe-arm safe-arm :mirror mirror
           :enable-button :right :gripper-button :left :visualize visualize))
    ((eq device-type :tablis)
     (send *ti* :main-loop :head head :torso nil :base nil
           :safe-arm safe-arm :safe-base nil :mirror mirror
           :enable-button :menu :gripper-button :trigger :visualize visualize))
    (t nil)))
