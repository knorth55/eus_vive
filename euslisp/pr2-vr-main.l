#!/usr/bin/env roseus

(load "package://eus_vive/euslisp/lib/pr2-vive-interface.l")
(load "package://eus_vive/euslisp/lib/pr2-oculus-interface.l")


(defun vive-init (&key (loop-enable t))
  (pr2-vive-init :loop-enable loop-enable)
  (send *ri* :angle-vector (send *pr2* :reset-pose))
  (send *ri* :stop-grasp :arms :wait nil)
  (send *ri* :wait-interpolation)
  (send *ri* :clear-costmap)
  (send *ti* :send-joy-feedback :larm)
  (send *ti* :send-joy-feedback :rarm))


(defun oculus-init (&key (loop-enable t))
  (pr2-oculus-init :loop-enable loop-enable)
  (send *ri* :angle-vector (send *pr2* :reset-pose))
  (send *ri* :stop-grasp :arms :wait nil)
  (send *ri* :wait-interpolation)
  (send *ri* :clear-costmap))


(defun init (&key (loop-enable t) (device-type :vive))
  (ros::roseus "pr2_vr_main" :anonymous nil)
  (if (eq device-type :oculus)
    (oculus-init :loop-enable loop-enable)
    (vive-init :loop-enable loop-enable))
  (send *irtviewer* :draw-objects)
  (x::window-main-one))


(defun main (&key (head t) (torso t) (base t) (safe-arm t) (safe-base nil) (mirror nil)
                  (visualize t) (loop-enable t) (device-type :vive))
  (init :loop-enable t :device-type device-type)
  (unless head
    (while (not (send *ti* :calibrate))
      (ros::spin-once)))
  (unless loop-enable (send *ti* :disable))
  (send *ti* :main-loop :head head :torso torso :base base
        :safe-arm safe-arm :safe-base safe-base :mirror mirror
        :enable-button :menu :gripper-button :trigger :visualize visualize))
