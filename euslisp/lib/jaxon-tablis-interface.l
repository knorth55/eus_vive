;; -*- mode: lisp;-*-

(require :jaxon-interface "package://hrpsys_ros_bridge_tutorials/euslisp/jaxon-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-move-base-vr-interface "package://eus_vive/euslisp/lib/robot-move-base-vr-interface.l")
(require :jaxon-vr-interface "package://eus_vive/euslisp/lib/jaxon-vr-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")
(require :robot-move-base-vive-interface "package://eus_vive/euslisp/lib/robot-move-base-vive-interface.l")
(require :robot-tablis-interface "package://eus_vive/euslisp/lib/robot-tablis-interface.l")
(require :robot-move-base-tablis-interface "package://eus_vive/euslisp/lib/robot-move-base-tablis-interface.l")


(defclass jaxon-tablis-interface
  :super robot-tablis-interface
  :slots ())


(defmethod jaxon-tablis-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for tablis
      (send self :set-val 'scale 1.0)
      (send self :set-val 'trigger-wait-count 5)
      (send self :set-val 'menu-wait-count 5)
      (send self :set-val 'trackpad-wait-count 5)
      (send self :set-val 'grip-wait-count 5)
      (send self :set-val 'larm-tablis-pose-topic-name "/master_larm_pose_orig")
      (send self :set-val 'rarm-tablis-pose-topic-name "/master_rarm_pose_orig")
      (send self :set-val 'lleg-tablis-pose-topic-name "/master_lleg_pose_orig")
      (send self :set-val 'rleg-tablis-pose-topic-name "/master_rleg_pose_orig")
      (send self :set-val 'larm-command-pose-topic-name "/master_larm_pose")
      (send self :set-val 'rarm-command-pose-topic-name "/master_rarm_pose")
      (send self :set-val 'lleg-command-pose-topic-name "/master_lleg_pose")
      (send self :set-val 'rleg-command-pose-topic-name "/master_rleg_pose")
      (send self :set-val 'larm-feedback-pose-topic-name "/slave_larm_pose")
      (send self :set-val 'rarm-feedback-pose-topic-name "/slave_rarm_pose")
      (send self :set-val 'lleg-feedback-pose-topic-name "/slave_lleg_pose")
      (send self :set-val 'rleg-feedback-pose-topic-name "/slave_rleg_pose")
      ))
  (:get-target-coords (arm &key (head t) (mirror nil))
    (let* ((target-arm (if mirror (send self :get-opposite-arm arm) arm))
           (tablis-coords
             (if (send self :get-arm-val target-arm :tablis-coords)
               (send (send self :get-arm-val target-arm :tablis-coords) :copy-worldcoords)))
           (target-pos (send tablis-coords :worldpos))
           (target-rot (send tablis-coords :worldrot))
           target-coords)
      (if mirror
        (progn
          (setq target-pos (send self :get-mirror-pos target-pos))
          (setq target-rot (send self :get-mirror-pos target-rot))
          (setq target-coords
                (make-coords :pos target-pos :rot target-rot)))
        (setq target-coords tablis-coords))
      tablis-coords))
  )


(defun jaxon-tablis-init (&key (loop-enable t))
  (jaxon-init)
  (make-jaxon-irtviewer :no-window t)
  (make-jaxon-camera-model :no-window t)
  (setq *ti* (instance jaxon-tablis-interface :init :loop-enable loop-enable))
  (send *ti* :ros-init))
