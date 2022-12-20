;; -*- mode: lisp;-*-

(ros::load-ros-manifest "baxter_core_msgs")

(require :baxter-interface "package://eus_vive/euslisp/lib/baxter-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :baxter-vr-interface "package://eus_vive/euslisp/lib/baxter-vr-interface.l")
(require :robot-tablis-interface "package://eus_vive/euslisp/lib/robot-tablis-interface.l")


(defclass baxter-tablis-interface
  :super robot-tablis-interface
  :slots (larm-thumb-open
          rarm-thumb-open))


(defmethod baxter-tablis-interface
  (:init (&rest args)
    ;; for tablis
    (send self :set-val 'scale 3.0)
    (send self :set-val 'trigger-wait-count 5)
    (send self :set-val 'menu-wait-count 5)
    (send self :set-val 'trackpad-wait-count 5)
    (send self :set-val 'grip-wait-count 5)
    (send self :set-val 'left-tablis-pose-topic-name "/master_larm_pose")
    (send self :set-val 'right-tablis-pose-topic-name "/master_rarm_pose")
    (send-super* :init args))
  (:get-hmd->tablis-coords (arm)
    (let* ((coords (send-super :get-hmd->tablis-coords arm))
           (btablis->hmd-coords (send self :get-btablis->hmd-coords))
           (rpy-angle
             (if btablis->hmd-coords (car (send btablis->hmd-coords :rpy-angle)))))
      (if (and coords rpy-angle)
        (progn
          (setq coords
                (send (make-coords :rpy (float-vector 0 (* -1 (elt rpy-angle 2)) 0))
                      :transform coords))
          coords)))))


(defun baxter-tablis-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
  (eus_vive::baxter-init :lgripper lgripper :rgripper rgripper :limit-in-front t)
  (make-baxter-irtviewer :no-window t)
  (make-baxter-camera-model :no-window t)
  (setq *ti* (instance baxter-tablis-interface :init :loop-enable loop-enable
                       :lgripper lgripper :rgripper rgripper)))
