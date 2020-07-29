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
  (:init (&key (loop-enable t))
    ;; for oculus
    (ros::subscribe hmd-pose-topic-name
                    geometry_msgs::PoseStamped #'send self :hmd-pose-cb :larm)
    (ros::subscribe left-controller-pose-topic-name
                    geometry_msgs::PoseStamped #'send self :controller-pose-cb :larm)
    (ros::subscribe right-controller-pose-topic-name
                    geometry_msgs::PoseStamped #'send self :controller-pose-cb :rarm)
    (send-super :init :loop-enable loop-enable))
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
    ;; TODO (knorth55): update get-target-coords for oculus
    (return-from get-target-coords nil))
  (:calib-controller ()
    ;; TODO (knorth55): update get-target-coords for oculus
    (return-from :calib-controller t)))


(provide :robot-oculus-interface)
