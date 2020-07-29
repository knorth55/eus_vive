;; -*- mode: lisp;-*-

(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "topic_tools")

(load "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(defclass robot-oculus-interface
  :super robot-vr-interface
  :slots ())


(defmethod robot-oculus-interface
  (:init (&key (loop-enable t))
    ;; for oculus
    ;; TODO (knorth55): subscribe oculus pose
    (send-super :init :loop-enable loop-enable))
  (:get-target-coords (arm &key (head t) (mirror nil))
    ;; TODO (knorth55): update get-target-coords for oculus
                      )
  (:calib-controller ()
    ;; TODO (knorth55): update get-target-coords for oculus
    (return-from :calib-controller t)))


(provide :robot-oculus-interface)
