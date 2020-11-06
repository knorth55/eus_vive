(require :baxter "package://eus_vive/euslisp/lib/baxter-util.l")
(load "package://baxtereus/baxter-interface.l")
(load "package://softhand_ros/euslisp/softhand-interface.l")
(load "package://softhand_ros/euslisp/softhand-v2-interface.l")


(unless (find-package "EUS_VIVE")
  (make-package "EUS_VIVE"))


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
         (instance softhand-interface :init :namespace "/lgripper"))
        ((equal lgripper-type :softhand-v2)
         (instance softhand-v2-interface :init :namespace "/lgripper"))
        (t nil)))
    (setq rgripper-interface
      (cond
        ((equal rgripper-type :softhand)
         (instance softhand-interface :init :namespace "/rgripper"))
        ((equal rgripper-type :softhand-v2)
         (instance softhand-v2-interface :init :namespace "/rgripper"))
        (t nil))))
  (:get-gripper-type (arm)
    (cond ((equal arm :larm) lgripper-type)
          ((equal arm :rarm) rgripper-type)
          (t nil)))
  (:get-gripper-interface (arm)
    (cond ((equal arm :larm) lgripper-interface)
          ((equal arm :rarm) rgripper-interface)
          (t nil)))
  (:start-grasp (&optional (arm :arms) &rest args)
    (if (equal arm :arms)
      (progn
        (send* self :start-grasp :larm :wait nil args)
        (send* self :start-grasp :rarm args))
      (cond
        ((equal (send self :get-gripper-type arm) :parallel)
         (send-super* :start-grasp arm args))
        ((or (equal (send self :get-gripper-type arm) :softhand)
             (equal (send self :get-gripper-type arm) :softhand-v2))
         (send (send self :get-gripper-interface arm) :start-grasp))
        (t nil))))
  (:stop-grasp (&optional (arm :arms) &rest args)
    (if (equal arm :arms)
      (progn
        (send* self :stop-grasp :larm :wait nil args)
        (send* self :stop-grasp :rarm args))
      (cond
        ((equal (send self :get-gripper-type arm) :parallel)
         (send-super* :stop-grasp arm args))
        ((or (equal (send self :get-gripper-type arm) :softhand)
             (equal (send self :get-gripper-type arm) :softhand-v2))
         (send (send self :get-gripper-interface arm) :stop-grasp))
        (t nil))))
  (:open-thumb (&optional (arm :arms))
    (dolist (a (if (eq arm :arms) (list :larm :rarm) (list arm)))
      (cond
        ((equal (send self :get-gripper-type a) :softhand-v2)
         (send (send self :get-gripper-interface a) :open-thumb))
        (t
         (ros::ros-warn ":open-thumb is invalid for this gripper type")
         nil))))
  (:close-thumb (&optional (arm :arms))
    (dolist (a (if (eq arm :arms) (list :larm :rarm) (list arm)))
      (cond
        ((equal (send self :get-gripper-type a) :softhand-v2)
         (send (send self :get-gripper-interface a) :close-thumb))
        (t
         (ros::ros-warn ":close-thumb is invalid for this gripper type")
         nil))))
  (:start-heater (&optional (arm :arms))
    (dolist (a (if (eq arm :arms) (list :larm :rarm) (list arm)))
      (cond
        ((equal (send self :get-gripper-type a) :softhand-v2)
         (send (send self :get-gripper-interface a) :start-heater))
        (t
         (ros::ros-warn ":start-heater is invalid for this gripper type")
         nil))))
  (:stop-heater (&optional (arm :arms))
    (dolist (a (if (eq arm :arms) (list :larm :rarm) (list arm)))
      (cond
        ((equal (send self :get-gripper-type a) :softhand-v2)
         (send (send self :get-gripper-interface a) :stop-heater))
        (t
         (ros::ros-warn ":stop-heater is invalid for this gripper type")
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
    ;; overwrite s0, e0, e1 joint limit
    ;; do not rotate s0, e0, e1 joint and stay arm in front of the robot
    (send *baxter* :left_s0 :max-angle 30)
    (send *baxter* :left_e0 :max-angle 30)
    (send *baxter* :left_e1 :min-angle 5)
    (send *baxter* :right_s0 :min-angle -30)
    (send *baxter* :right_e0 :min-angle -30)
    (send *baxter* :right_e1 :min-angle 5)
    (when (equal lgripper :parallel) (send *ri* :calib-grasp :larm))
    (when (equal rgripper :parallel) (send *ri* :calib-grasp :rarm))))

(provide :baxter-interface)
