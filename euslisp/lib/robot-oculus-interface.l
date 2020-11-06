;; -*- mode: lisp;-*-

(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "topic_tools")

(load "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(defclass robot-oculus-interface
  :super robot-vr-interface
  :slots (hmd-pose-topic-name
          hmd-coords
          larm-controller-coords
          left-controller-pose-topic-name
          rarm-controller-coords
          right-controller-pose-topic-name
          ))


(defmethod robot-oculus-interface
  (:init (&rest args)
    ;; for oculus
    (ros::subscribe hmd-pose-topic-name
                    geometry_msgs::PoseStamped #'send self :hmd-pose-cb :larm)
    (ros::subscribe left-controller-pose-topic-name
                    geometry_msgs::PoseStamped #'send self :controller-pose-cb :larm)
    (ros::subscribe right-controller-pose-topic-name
                    geometry_msgs::PoseStamped #'send self :controller-pose-cb :rarm)
    (send-super* :init args))
  (:enable ()
    (send self :reset :loop-enable t)
    ;; TODO (knorth55): map oculus controller button to enable arm motion
    (send self :set-arm-val :larm :enable t)
    (send self :set-arm-val :rarm :enable t))
  (:controller-pose-cb (arm msg)
    (send self :set-arm-val arm :controller-coords (ros::tf-pose-stamped->coords msg)))
  (:hmd-pose-cb (arm msg)
    (send self :set-val 'hmd-coords (ros::tf-pose-stamped->coords msg)))
  (:get-head-ypr-angle ()
    (car (send hmd-coords :rpy-angle)))
  (:get-target-coords (arm &key (head t) (mirror nil))
    (unless head
      (ros::ros-error "oculus is only available when head is t.")
      (return-from :get-target-coords nil))
    (when mirror
      (ros::ros-error "oculus is only available when mirror is nil.")
      (return-from :get-target-coords nil))
    (let* ((head-coords (send self :get-head-end-coords))
           (robot-height (elt (send head-coords :worldpos) 2))
           (controller-coords
             (send (send self :get-arm-val arm :controller-coords) :copy-worldcoords))
           target-pos target-rot target-coords)
      (when controller-coords
        (setq target-pos
              (v+ (send head-coords :worldpos)
                  (v- (send controller-coords :worldpos)
                      (send hmd-coords :worldpos))))
        (setq target-rot (send controller-coords :worldrot))
        (setq target-coords
              (make-coords :pos (float-vector
                                  (+ head->shoulder-x-distance (* scale (elt target-pos 0)))
                                  (* scale (elt target-pos 1))
                                  (- robot-height (* scale (- robot-height (elt target-pos 2)))))
                           :rot target-rot))
        target-coords)))
  (:calib-controller ()
    ;; TODO (knorth55): update get-target-coords for oculus
    (return-from :calib-controller t)))


(provide :robot-oculus-interface)
