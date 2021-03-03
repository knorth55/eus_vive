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
    ;; for vive
    (send self :set-val 'trigger-wait-count 5)
    (send self :set-val 'menu-wait-count 5)
    (send self :set-val 'trackpad-wait-count 5)
    (send self :set-val 'grip-wait-count 5)
    (send-super* :init args))
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
  (objects (list *baxter*))
  (setq *camera-model*
        (make-camera-from-param :pwidth 600 :pheight 600 :fx 400 :fy 400 :cx 319.5 :cy 319.5
                                :name "camera" :create-viewer t))
  (send *camera-model* :translate #f(1500 0 600))
  (send *camera-model* :rotate -pi/2 :y :world)
  (send *camera-model* :rotate -pi/2 :x :world)
  (send *camera-model* :rotate -0.30 :y :world)
  (send *irtviewer* :change-background (float-vector 1 1 1))
  (send *irtviewer* :draw-floor 100)
  (send *irtviewer* :floor-color #f(0 0 0))
  (setq *background-cube* (make-cube 10 6000 6000))
  (send *background-cube* :set-color #f(1 1 1))
  (send *background-cube* :translate #f(-1000 0 0))
  (setq *ti* (instance baxter-vive-interface :init :loop-enable loop-enable
                       :lgripper lgripper :rgripper rgripper)))
