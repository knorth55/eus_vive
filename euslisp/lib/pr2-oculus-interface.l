;; -*- mode: lisp;-*-
(load "package://pr2eus/pr2-interface.l")
(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :pr2-vr-interface "package://eus_vive/euslisp/lib/pr2-vr-interface.l")
(require :robot-oculus-interface "package://eus_vive/euslisp/lib/robot-oculus-interface.l")


(defclass pr2-oculus-interface
  :super robot-oculus-interface
  :slots ())


(defmethod pr2-oculus-interface
  (:init (&rest args)
    ;; for oculus
    (send self :set-val 'hmd-pose-topic-name "/oculus/hmd/pose_stamped")
    (send self :set-val 'left-controller-pose-topic-name "/oculus/left_controller/pose_stamped")
    (send self :set-val 'right-controller-pose-topic-name "/oculus/right_controller/pose_stamped")
    (send-super* :init args)))


(defun pr2-oculus-init (&key (loop-enable t))
  (pr2-init)
  (objects (list *pr2*))
  (setq *camera-model*
        (make-camera-from-param :pwidth 640 :pheight 640 :fx 400 :fy 400 :cx 319.5 :cy 319.5
                                :name "camera" :create-viewer t :no-window t))
  (send *camera-model* :translate #f(1500 0 800))
  (send *camera-model* :rotate -1.57 :y :world)
  (send *camera-model* :rotate -1.57 :x :world)
  (setq *ti* (instance pr2-oculus-interface :init :loop-enable loop-enable)))
