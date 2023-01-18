;; -*- mode: lisp;-*-

(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "topic_tools")

(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")


(defclass robot-oculus-interface
  :super robot-teleop-interface
  :slots (hmd-pose-topic-name
          hmd-coords
          larm-controller-coords
          left-controller-pose-topic-name
          rarm-controller-coords
          right-controller-pose-topic-name
          ))


(defmethod robot-oculus-interface
  (:ros-init ()
    (prog1
      (send-super :ros-init)
      ;; for oculus
      (ros::subscribe hmd-pose-topic-name
                      geometry_msgs::PoseStamped #'send self :hmd-pose-cb :larm)
      (ros::subscribe left-controller-pose-topic-name
                      geometry_msgs::PoseStamped #'send self :controller-pose-cb :larm)
      (ros::subscribe right-controller-pose-topic-name
                      geometry_msgs::PoseStamped #'send self :controller-pose-cb :rarm)))
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
    (if (not head)
      (progn
        (ros::ros-error "oculus is only available when head is t.")
        (return-from :get-target-coords nil)))
    (if mirror
      (progn
        (ros::ros-error "oculus is only available when mirror is nil.")
        (return-from :get-target-coords nil)))
    (let ((controller-coords
            (send (send self :get-arm-val arm :controller-coords) :copy-worldcoords))
          (head-coords (send self :get-head-end-coords))
          target-pos target-rot target-coords)
      (if controller-coords
        (progn
          (setq target-pos
                (v+ (send head-coords :worldpos)
                    (v- (send controller-coords :worldpos)
                        (send hmd-coords :worldpos))))
          (setq target-rot (send controller-coords :worldrot))
          (setq target-coords
                (send self :get-target-coords-from-pos-rot
                      target-pos target-rot :head head :mirror mirror))
          target-coords))))
  (:calib-controller ()
    ;; TODO (knorth55): update get-target-coords for oculus
    (return-from :calib-controller t)))


(provide :robot-oculus-interface)
