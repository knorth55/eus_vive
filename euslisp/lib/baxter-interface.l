(require :baxter "package://baxtereus//baxter-util.l")
(load "package://baxtereus/baxter-interface.l")
(load "package://softhand_ros/euslisp/softhand-interface.l")
(load "package://softhand_ros/euslisp/softhand-v2-interface.l")


(unless (find-package "EUS_VIVE")
  (make-package "EUS_VIVE"))


(defmethod baxter-robot
  (:reset-teleop-pose ()
    (send self :angle-vector
          (float-vector 0.0 0.0 -25 -40 70 -40 80  130
                            0.0 -25  40 70  40 80 -130))))


(defclass eus_vive::baxter-interface
  :super baxter-interface
  :slots (lgripper-type
          lgripper-interface
          rgripper-type
          rgripper-interface))


(defmethod eus_vive::baxter-interface
  (:init (&key (lgripper :parallel) (rgripper :parallel) &rest args &allow-other-keys)
    (send-super* :init args)
    (setq lgripper-type lgripper)
    (setq rgripper-type rgripper)
    (setq lgripper-interface
      (cond
        ((equal lgripper-type :softhand)
         (setq lgripper-interface (instance softhand-interface :init :namespace "/lgripper")))
        ((equal lgripper-type :softhand-v2)
         (setq lgripper-interface (instance softhand-v2-interface :init :namespace "/lgripper")))
        (t nil)))
    (setq rgripper-interface
      (cond
        ((equal rgripper-type :softhand)
         (setq rgripper-interface (instance softhand-interface :init :namespace "/rgripper")))
        ((equal rgripper-type :softhand-v2)
         (setq rgripper-interface (instance softhand-v2-interface :init :namespace "/rgripper")))
        (t nil))))
  (:start-grasp (&optional (arm :arms) &rest args)
    (if (equal arm :arms)
      (progn
        (send* self :start-grasp :larm :wait nil args)
        (send* self :start-grasp :rarm args))
      (cond
        ((equal (if (equal arm :larm) lgripper-type rgripper-type) :parallel)
         (send-super* :start-grasp arm args))
        ((or (equal (if (equal arm :larm) lgripper-type rgripper-type) :softhand)
             (equal (if (equal arm :larm) lgripper-type rgripper-type) :softhand-v2))
         (send (if (equal arm :larm) lgripper-interface rgripper-interface) :start-grasp))
        (t nil))))
  (:stop-grasp (&optional (arm :arms) &rest args)
    (if (equal arm :arms)
      (progn
        (send* self :stop-grasp :larm :wait nil args)
        (send* self :stop-grasp :rarm args))
      (cond
        ((equal (if (equal arm :larm) lgripper-type rgripper-type) :parallel)
         (send-super* :stop-grasp arm args))
        ((or (equal (if (equal arm :larm) lgripper-type rgripper-type) :softhand)
             (equal (if (equal arm :larm) lgripper-type rgripper-type) :softhand-v2))
         (send (if (equal arm :larm) lgripper-interface rgripper-interface) :stop-grasp))
        (t nil))))
  (:open-thumb (&optional (arm :arms))
    (dolist (a (if (eq arm :arms) (list :larm :rarm) (list arm)))
      (cond
        ((equal (if (equal a :larm) lgripper-type rgripper-type) :softhand-v2)
         (send (if (equal a :larm) lgripper-interface rgripper-interface) :open-thumb))
        (t
         (ros::ros-error ":open-thumb is invalid for this gripper type")
         nil))))
  (:close-thumb (&optional (arm :arms))
    (dolist (a (if (eq arm :arms) (list :larm :rarm) (list arm)))
      (cond
        ((equal (if (equal a :larm) lgripper-type rgripper-type) :softhand-v2)
         (send (if (equal a :larm) lgripper-interface rgripper-interface) :close-thumb))
        (t
         (ros::ros-error ":close-thumb is invalid for this gripper type")
         nil)))))


(defun eus_vive::baxter-init
  (&key (safe t) (type :default-controller) (moveit t)
        (lgripper :parallel) (rgripper :parallel))
  (let (mvit-env mvit-rb)
    (when moveit
      (setq mvit-env (instance baxter-moveit-environment))
      (setq mvit-rb (instance baxter-robot :init)))
    (when (not (boundp '*ri*))
      (setq *ri* (instance eus_vive::baxter-interface :init :type type
                           :moveit-environment mvit-env
                           :moveit-robot mvit-rb
                           :controller-timeout 10
                           :lgripper lgripper
                           :rgripper rgripper)))
    (when (not (boundp '*baxter*))
      (if safe
        (setq *baxter* (instance baxter-robot-safe :init))
        (setq *baxter* (instance baxter-robot :init))))
    (when (equal lgripper :parallel) (send *ri* :calib-grasp :larm))
    (when (equal rgripper :parallel) (send *ri* :calib-grasp :rarm))))

(provide :baxter-interface)
