(require :baxter "package://eus_vive/euslisp/lib/baxter-util.l")
(load "package://baxtereus/baxter-interface.l")
(load "package://softhand_ros/euslisp/softhand-interface.l")
(load "package://softhand_ros/euslisp/softhand-v2-interface.l")


(if (not (find-package "EUS_VIVE"))
  (make-package "EUS_VIVE"))


(defclass eus_vive::baxter-interface
  :super baxter-interface
  :slots (lgripper-type
          lgripper-interface
          rgripper-type
          rgripper-interface))


(defmethod eus_vive::baxter-interface
  (:init (&rest args &key (lgripper :parallel) (rgripper :parallel) &allow-other-keys)
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
    (cond
      ((equal arm :arms)
       (and (send* self :start-grasp-step :larm args)
            (send* self :start-grasp-step :rarm args)))
      (t (send* self :start-grasp-step arm args))))
  (:start-grasp-step (arm &rest args)
    (cond
      ((equal (send self :get-gripper-type arm) :parallel)
       (send-super* :start-grasp arm args))
      ((or (equal (send self :get-gripper-type arm) :softhand)
           (equal (send self :get-gripper-type arm) :softhand-v2))
       (send (send self :get-gripper-interface arm) :start-grasp))
      (t nil)))
  (:stop-grasp (&optional (arm :arms) &rest args)
    (cond
      ((equal arm :arms)
       (and (send* self :stop-grasp-step :larm args)
            (send* self :stop-grasp-step :rarm args)))
      (t (send* self :stop-grasp-step arm args))))
  (:stop-grasp-step (arm &rest args)
    (cond
      ((equal (send self :get-gripper-type arm) :parallel)
       (send-super* :stop-grasp arm args))
      ((or (equal (send self :get-gripper-type arm) :softhand)
           (equal (send self :get-gripper-type arm) :softhand-v2))
       (send (send self :get-gripper-interface arm) :stop-grasp))
      (t nil)))
  (:open-thumb (&optional (arm :arms))
    (cond
      ((equal arm :arms)
       (let ((larm-open-thumb-p (send self :open-thumb-step :larm))
             (rarm-open-thumb-p (send self :open-thumb-step :rarm)))
         (and larm-open-thumb-p rarm-open-thumb-p)))
      (t (send self :open-thumb-step arm))))
  (:open-thumb-step (arm)
    (cond
      ((equal (send self :get-gripper-type arm) :softhand-v2)
       (send (send self :get-gripper-interface arm) :open-thumb))
      (t
       (ros::ros-warn ":open-thumb is invalid for this gripper type")
       nil)))
  (:close-thumb (&optional (arm :arms))
    (cond
      ((equal arm :arms)
       (let ((larm-close-thumb-p (send self :close-thumb-step :larm))
             (rarm-close-thumb-p (send self :close-thumb-step :rarm)))
         (and larm-close-thumb-p rarm-close-thumb-p)))
      (t (send self :close-thumb-step arm))))
  (:close-thumb-step (arm)
    (cond
      ((equal (send self :get-gripper-type arm) :softhand-v2)
       (send (send self :get-gripper-interface arm) :close-thumb))
      (t
       (ros::ros-warn ":close-thumb is invalid for this gripper type")
       nil)))
  (:start-heater (&optional (arm :arms))
    (cond
      ((equal arm :arms)
       (let ((larm-start-heater-p (send self :start-heater-step :larm))
             (rarm-start-heater-p (send self :start-heater-step :rarm)))
         (and larm-start-heater-p rarm-start-heater-p)))
      (t (send self :start-heater-step arm))))
  (:start-heater-step (arm)
    (cond
      ((equal (send self :get-gripper-type arm) :softhand-v2)
       (send (send self :get-gripper-interface arm) :start-heater))
      (t
       (ros::ros-warn ":start-heater is invalid for this gripper type")
       nil)))
  (:stop-heater (&optional (arm :arms))
    (cond
      ((equal arm :arms)
       (let ((larm-stop-heater-p (send self :stop-heater-step :larm))
             (rarm-stop-heater-p (send self :stop-heater-step :rarm)))
         (and larm-stop-heater-p rarm-stop-heater-p)))
      (t (send self :stop-heater-step arm))))
  (:stop-heater-step (arm)
    (cond
      ((equal (send self :get-gripper-type arm) :softhand-v2)
       (send (send self :get-gripper-interface arm) :stop-heater))
      (t
       (ros::ros-warn ":stop-heater is invalid for this gripper type")
       nil))))


(defun eus_vive::baxter-init
  (&key (safe t) (type :default-controller) (moveit t)
        (lgripper :softhand) (rgripper :softhand) (limit-in-front nil))
  (let (mvit-env mvit-rb)
    (if moveit
      (progn
        (setq mvit-env (instance baxter-moveit-environment))
        (setq mvit-rb (instance baxter-robot :init))))
    (if (not (boundp '*ri*))
      (setq *ri* (instance eus_vive::baxter-interface :init :type type
                           :moveit-environment mvit-env
                           :moveit-robot mvit-rb
                           :controller-timeout 10
                           :lgripper lgripper
                           :rgripper rgripper)))
    (if (not (boundp '*baxter*))
      (if safe
        (setq *baxter* (instance baxter-robot-safe :init))
        (setq *baxter* (instance baxter-robot :init))))
    ;; overwrite s0, e0, e1 joint limit
    ;; do not rotate s0, e0, e1 joint and stay arm in front of the robot
    (if limit-in-front
      (progn
        (send *baxter* :left_s0 :max-angle 30)
        (send *baxter* :left_e0 :max-angle 30)
        (send *baxter* :left_e1 :min-angle 5)
        (send *baxter* :right_s0 :min-angle -30)
        (send *baxter* :right_e0 :min-angle -30)
        (send *baxter* :right_e1 :min-angle 5)))
    (if (equal lgripper :parallel) (send *ri* :calib-grasp :larm))
    (if (equal rgripper :parallel) (send *ri* :calib-grasp :rarm))))

(provide :baxter-interface)
