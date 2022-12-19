;; -*- mode: lisp;-*-

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(if (not (assoc :init-move-base-org (send robot-vr-interface :methods)))
  (rplaca (assoc :init (send robot-vr-interface :methods)) :init-move-base-org))
(if (not (assoc :reset-move-base-org (send robot-vr-interface :methods)))
  (rplaca (assoc :reset (send robot-vr-interface :methods)) :reset-move-base-org))
(if (not (assoc :enable-cb-move-base-org (send robot-vr-interface :methods)))
  (rplaca (assoc :enable-cb (send robot-vr-interface :methods)) :enable-cb-move-base-org))


(defmethod robot-vr-interface
  (:init (&rest args)
    (send* self :init-move-base-org args)
    ;; for move base
    (send self :set-val 'joy-org-topic-name "/joy_org")
    (send self :set-val 'joy-other-topic-name "/joy_other")
    (ros::advertise joy-other-topic-name sensor_msgs::Joy 1))
  ;; redefine :reset
  (:reset (&key (loop-enable t))
    (send self :reset-move-base-org :loop-enable loop-enable)
    (send robot-interface :clear-costmap)
    (send self :set-val 'vx 0.0)
    (send self :set-val 'vy 0.0)
    (send self :set-val 'vw 0.0)
    (send self :set-val 'base-enable nil))
  ;; redefine :base-cb
  (:base-cb (&key (safe t) (mirror nil))
    (let (msg (axes (make-list 29 :initial-element 0))
              (buttons (make-list 17 :initial-element 0)))
      (cond
        ((not (or larm-trigger rarm-trigger))
         (setf (elt buttons 10) 1)
         (setf (elt buttons 12)
               (if (and larm-trackpad (not rarm-trackpad)) 1 0))
         (setf (elt buttons 14)
               (if (and (not larm-trackpad) rarm-trackpad) 1 0)))
        ((and rarm-trigger
              (or (> (abs vx) vx-thresh) (> (abs vy) vy-thresh) (> (abs vw) vw-thresh)))
         ;; for unsafe teleop
         (if (and (not safe) larm-trigger) (setf (elt buttons 9) 1))
         (setf (elt buttons 10) 1)
         (setf (elt axes 3)
               (* (if mirror -1.0 1.0)
                  (* vx-scale (if (> (abs vx) vx-thresh) vx 0.0))))
         (setf (elt axes 2)
               (* (if mirror -1.0 1.0)
                  (* vy-scale (if (> (abs vy) vy-thresh) vy 0.0))))
         (setf (elt axes 0)
               (* (if mirror -1.0 1.0)
                  (* vw-scale (if (> (abs vw) vw-thresh) vw 0.0)))))
        (t nil))
      (setq msg (instance sensor_msgs::Joy :init))
      (send msg :header :stamp (ros::time-now))
      (send msg :axes axes)
      (send msg :buttons buttons)
      (ros::publish joy-other-topic-name msg)))
  ;; switch joy from ps3joy to vive
  (:switch-joy (joy-topic-name)
    (let ((joy-mux-service-name "/multiple_joystick_mux/select")
          mux-req)
      (setq mux-req (instance topic_tools::MuxSelectRequest :init))
      (send mux-req :topic joy-topic-name)
      (ros::service-call joy-mux-service-name mux-req)))
  (:switch-joy-to-controller ()
    (send self :switch-joy joy-other-topic-name))
  (:switch-joy-to-ps3joy ()
    (send self :switch-joy joy-org-topic-name))
  ;; redefine :enable-cb for base
  (:enable-cb (&key (mirror nil) (base t) (button :menu))
    (send self :enable-cb-move-base-org :mirror mirror :button button)
    (if base (send self :enable-base)))
  (:enable-base ()
    (cond
      ((and (not larm-enable) (not rarm-enable))
       (if (not base-enable) (send self :switch-joy-to-controller))
       (send self :set-val 'base-enable t))
      ((or larm-enable rarm-enable)
       (if base-enable (send self :switch-joy-to-ps3joy))
       (send self :set-val 'base-enable nil))
      (t nil)))
  ;; redefine :motion-cb for base
  (:motion-cb (&key (head t) (torso t) (base t) (safe-arm t) (safe-base nil) (mirror nil)
                    (gripper-button :trigger))
    (let (visualize-arm-coords)
      (cond
        ((or larm-enable rarm-enable)
         (setq visualize-arm-coords
               (send self :arm-motion-cb :head head :torso torso :safe safe-arm :mirror mirror
                     :gripper-button gripper-button)))
        ((and loop-enable base-enable)
         (if base (send self :base-cb :safe safe-base :mirror mirror)))
        (t nil))
      visualize-arm-coords))
  ;; redefine :main-loop-step for base
  (:main-loop-step (&key (head t) (torso t) (base t) (safe-arm t) (safe-base nil) (mirror nil)
                         (enable-button :menu) (gripper-button :trigger) (visualize t))
    (let (visualize-arm-coords)
      (send self :update-current-end-coords)
      (send self :enable-cb :mirror mirror :base base :button enable-button)
      (setq visualize-arm-coords
            (send self :motion-cb :head head :torso torso
                  :base base :safe-arm safe-arm :safe-base safe-base :mirror mirror
                  :gripper-button gripper-button))
      (if (and head loop-enable) (send self :head-cb))
      (if visualize (send self :visualize visualize-arm-coords)))))

(provide :robot-move-base-vr-interface)
