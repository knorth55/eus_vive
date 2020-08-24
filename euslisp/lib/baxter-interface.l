(require :baxter "package://baxtereus//baxter-util.l")
(load "package://baxtereus/baxter-interface.l")
(load "package://softhand_ros/euslisp/softhand-interface.l")


(unless (find-package "EUS_VIVE")
  (make-package "EUS_VIVE"))


(defmethod baxter-robot
  (:reset-teleop-pose ()
    (send self :angle-vector
          (float-vector 0.0
                        0.812988 -39.9023 -35.5298 108.896 114.06 -67.522 -13.8428
                        -0.812988 -39.9023 35.5298 108.896 -114.06 -67.522 13.8428))))


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
    (when (equal lgripper-type :softhand)
      (setq lgripper-interface (instance softhand-interface :init :namespace "/lgripper")))
    (when (equal rgripper-type :softhand)
      (setq rgripper-interface (instance softhand-interface :init :namespace "/rgripper"))))
  (:start-grasp (&optional (arm :arms) &rest args)
    (if (equal arm :arms)
      (progn
        (send* self :start-grasp :larm :wait nil args)
        (send* self :start-grasp :rarm args))
      (cond
        ((equal (if (equal arm :larm) lgripper-type rgripper-type) :parallel)
         (send-super* :start-grasp arm args))
        ((equal (if (equal arm :larm) lgripper-type rgripper-type) :softhand)
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
        ((equal (if (equal arm :larm) lgripper-type rgripper-type) :softhand)
         (send (if (equal arm :larm) lgripper-interface rgripper-interface) :stop-grasp))
        (t nil)))))


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
