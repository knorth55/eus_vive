;; -*- mode: lisp;-*-
(ros::load-ros-manifest "baxter_core_msgs")

(require :baxter-interface "package://eus_vive/euslisp/lib/baxter-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :baxter-vr-interface "package://eus_vive/euslisp/lib/baxter-vr-interface.l")
(require :robot-oculus-interface "package://eus_vive/euslisp/lib/robot-oculus-interface.l")


(defclass baxter-oculus-interface
  :super robot-oculus-interface
  :slots ())


(defmethod baxter-oculus-interface
  (:init (&rest args)
    ;; for oculus
    (send self :set-val 'hmd-pose-topic-name "/oculus/hmd/pose_stamped")
    (send self :set-val 'left-controller-pose-topic-name "/oculus/left_controller/pose_stamped")
    (send self :set-val 'right-controller-pose-topic-name "/oculus/right_controller/pose_stamped")
    (send-super* :init args)))


(defun baxter-oculus-init (&key (lgripper :parallel) (rgripper :parallel) (loop-enable t))
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
  (setq *ti* (instance baxter-oculus-interface :init :loop-enable loop-enable
                       :lgripper lgripper :rgripper rgripper)))
