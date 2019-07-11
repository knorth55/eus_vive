;; -*- mode: lisp;-*-

(load "package://pr2eus/pr2-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")

(defclass pr2-vive-interface
  :super robot-move-base-vive-interface
  :slots ())


(defmethod pr2-vive-interface
  (:init ()
    (send self :set-val 'robot *pr2*)
    (send self :set-val 'robot-interface *ri*)
    (send self :set-val 'rate 10)
    ;; for vive
    (send self :set-val 'hmd-frame-id "/hmd")
    (send self :set-val 'bvive-frame-id "/lighthouse_LHB_11CFA4E1")
    (send self :set-val 'cvive-frame-id "/lighthouse_LHB_8E924CC3")
    (send self :set-val 'feedback-topic-name "/vive/set_feedback")
    (send self :set-val 'larm-vive-frame-id "/controller_LHR_FD35BD42")
    (send self :set-val 'rarm-vive-frame-id "/controller_LHR_F7AFBF47")
    ;; for move base
    (send self :set-val 'joy-org-topic-name "/joy_org")
    (send self :set-val 'joy-other-topic-name "/joy_other")
    ;; for pr2
    (send self :set-val 'scale 1.5)
    (send self :set-val 'av-tm 0.3)
    (send self :set-val 'av-scale 8.0)
    (send self :set-val 'min-time 0.3)
    (send self :set-val 'vx-thresh 0.3)
    (send self :set-val 'vy-thresh 0.3)
    (send self :set-val 'vw-thresh 0.3)
    (send self :set-val 'vx-scale 1.0)
    (send self :set-val 'vy-scale 1.0)
    (send self :set-val 'vw-scale 1.0)
    (send self :set-val 'arm-length 600)
    (send self :set-val 'head->shoulder-x-distance 100)
    (send self :set-val 'head->shoulder-z-distance 50)
    (send self :set-val 'gripper-status-topic-name
          '(format nil "/~A_gripper_controller/gripper_action/status" (if (eq arm :larm) "l" "r")))
    (send-super :init))
  (:angle-vector (&rest args)
    (send* robot-interface :angle-vector args)))


(defun pr2-vive-init ()
  (pr2-init)
  (objects (list *pr2*))
  (setq *ti* (instance pr2-vive-interface :init)))
