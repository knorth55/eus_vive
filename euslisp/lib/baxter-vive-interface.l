;; -*- mode: lisp;-*-

(load "package://baxtereus/baxter-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")

(defclass baxter-vive-interface
  :super robot-vive-interface
  :slots ())


(defmethod baxter-vive-interface
  (:init ()
    (send self :set-val 'robot *baxter*)
    (send self :set-val 'robot-interface *ri*)
    (send self :set-val 'rate 10)
    ;; for vive
    (send self :set-val 'hmd-frame-id "/hmd")
    (send self :set-val 'bvive-frame-id "/lighthouse_LHB_11CFA4E1")
    (send self :set-val 'cvive-frame-id "/lighthouse_LHB_8E924CC3")
    (send self :set-val 'feedback-topic-name "/vive/set_feedback")
    (send self :set-val 'larm-vive-frame-id "/controller_LHR_FD35BD42")
    (send self :set-val 'rarm-vive-frame-id "/controller_LHR_F7AFBF47")
    ;; for baxter
    (send self :set-val 'scale 1.5)
    (send self :set-val 'av-tm :fast)
    (send self :set-val 'av-scale 1.0)
    (send self :set-val 'min-time 0.1)
    (send self :set-val 'arm-length 1000)
    (send self :set-val 'head->shoulder-x-distance 0)
    (send self :set-val 'head->shoulder-z-distance 30)
    (send-super :init))
  (:angle-vector (&rest args)
    (send* robot-interface :angle-vector-raw args)))


(defun baxter-vive-init ()
  (baxter-init)
  (objects (list *baxter*))
  (setq *ti* (instance baxter-vive-interface :init)))
