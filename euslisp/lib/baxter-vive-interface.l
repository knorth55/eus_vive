;; -*- mode: lisp;-*-
(ros::load-ros-manifest "baxter_core_msgs")

(require :baxter-interface "package://eus_vive/euslisp/lib/baxter-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :baxter-vr-interface "package://eus_vive/euslisp/lib/baxter-vr-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")


(defclass baxter-vive-interface
  :super robot-vive-interface
  :slots (larm-thumb-open
          rarm-thumb-open))


(defmethod baxter-vive-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for vive
      (send self :set-val 'scale 3.0)
      (send self :set-val 'trigger-wait-count 5)
      (send self :set-val 'menu-wait-count 5)
      (send self :set-val 'trackpad-wait-count 5)
      (send self :set-val 'grip-wait-count 5)))
  (:get-hmd->vive-coords (arm)
    (let* ((coords (send-super :get-hmd->vive-coords arm))
           (bvive->hmd-coords (send self :get-bvive->hmd-coords))
           (rpy-angle
             (if bvive->hmd-coords (car (send bvive->hmd-coords :rpy-angle)))))
      (if (and coords rpy-angle)
        (progn
          (setq coords
                (send (make-coords :rpy (float-vector 0 (* -1 (elt rpy-angle 2)) 0))
                      :transform coords))
          coords)))))


(defun baxter-vive-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
  (eus_vive::baxter-init :lgripper lgripper :rgripper rgripper :limit-in-front t)
  (make-baxter-irtviewer :no-window t)
  (make-baxter-camera-model :no-window t)
  (setq *ti* (instance baxter-vive-interface :init :loop-enable loop-enable
                       :lgripper lgripper :rgripper rgripper))
  (send *ti* :ros-init))
