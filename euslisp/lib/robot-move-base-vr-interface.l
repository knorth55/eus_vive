;; -*- mode: lisp;-*-

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(if (not (assoc :init-move-base-org (send robot-vr-interface :methods)))
  (rplaca (assoc :init (send robot-vr-interface :methods)) :init-move-base-org))
(if (not (assoc :ros-init-move-base-org (send robot-vr-interface :methods)))
  (rplaca (assoc :ros-init (send robot-vr-interface :methods)) :ros-init-move-base-org))
(if (not (assoc :reset-move-base-org (send robot-vr-interface :methods)))
  (rplaca (assoc :reset (send robot-vr-interface :methods)) :reset-move-base-org))
(if (not (assoc :enable-cb-move-base-org (send robot-vr-interface :methods)))
  (rplaca (assoc :enable-cb (send robot-vr-interface :methods)) :enable-cb-move-base-org))


(defmethod robot-vr-interface
  (:init (&rest args)
    (prog1
      (send* self :init-move-base-org args)
      ;; for move base
      (send self :set-val 'joy-org-topic-name "/joy_org")
      (send self :set-val 'joy-other-topic-name "/joy_other")))
  (:ros-init ()
    (prog1
      (send self :ros-init-move-base-org)
      (ros::advertise joy-other-topic-name sensor_msgs::Joy 1)))
  ;; redefine :reset
  (:reset (&key (loop-enable t))
    (send self :reset-move-base-org :loop-enable loop-enable)
    (if (assoc :clear-costmap (send robot-interface :methods))
      (send robot-interface :clear-costmap))
    (send self :set-val 'vx 0.0)
    (send self :set-val 'vy 0.0)
    (send self :set-val 'vw 0.0)
    (send self :set-val 'base-enable nil))
  ;; methods for base-cb
  (:get-base-safe-button (base-safe-button)
     (cond
       ((equal base-safe-button t) t)
       ((equal base-safe-button nil) nil)
       (t (send self :get-val base-safe-button))))
  (:get-base-unsafe-button (base-unsafe-button)
     (cond
       ((equal base-unsafe-button t) t)
       ((equal base-unsafe-button nil) nil)
       (t (send self :get-val base-unsafe-button))))
  (:get-torso-up-button (torso-up-button)
    (if torso-up-button (send self :get-val torso-up-button)))
  (:get-torso-down-button (torso-down-button)
    (if torso-down-button (send self :get-val torso-down-button)))
  (:check-torso-mode (safe-button-p unsafe-button-p
                      torso-up-button-p torso-down-button-p)
    (and
      (null (or safe-button-p unsafe-button-p))
      (or torso-up-button-p torso-down-button-p)))
  (:check-base-mode (safe-button-p)
    (and safe-button-p
         (or (> (abs vx) vx-thresh) (> (abs vy) vy-thresh) (> (abs vw) vw-thresh))))
  ;; redefine :base-cb
  (:base-cb (&key (safe t) (mirror nil)
                  (safe-button 'rarm-trigger)
                  (unsafe-button 'larm-trigger)
                  (torso-up-button 'larm-trackpad)
                  (torso-down-button 'rarm-trackpad))
    (let ((msg (instance sensor_msgs::Joy :init))
          (axes (make-list 29 :initial-element 0))
          (buttons (make-list 17 :initial-element 0))
          (safe-button-p (send self :get-base-safe-button safe-button))
          (unsafe-button-p (send self :get-base-unsafe-button unsafe-button))
          (torso-up-button-p (send self :get-torso-up-button torso-up-button))
          (torso-down-button-p (send self :get-torso-down-button torso-down-button)))
      (cond
        ;; torso mode
        ((send self :check-torso-mode safe-button-p unsafe-button-p
               torso-up-button-p torso-down-button-p)
         ;; deadman
         (setf (elt buttons joy-deadman-button-index) 1)
         ;; torso up
         (setf (elt buttons joy-torso-up-button-index)
               (if (and torso-up-button-p (not torso-down-button-p)) 1 0))
         ;; torso down
         (setf (elt buttons joy-torso-down-button-index)
               (if (and (not torso-up-button-p) torso-down-button-p) 1 0)))
        ;; base mode
        ((send self :check-base-mode safe-button-p)
         ;; deadman
         (setf (elt buttons joy-deadman-button-index) 1)
         ;; unsafe teleop
         (if (and (not safe) unsafe-button-p)
           (setf (elt buttons joy-unsafe-teleop-button-index) 1))
         ;; x translation
         (setf (elt axes joy-vx-axes-index)
               (* (if mirror -1.0 1.0)
                  (* vx-scale (if (> (abs vx) vx-thresh) vx 0.0))))
         ;; y translation
         (setf (elt axes joy-vy-axes-index)
               (* (if mirror -1.0 1.0)
                  (* vy-scale (if (> (abs vy) vy-thresh) vy 0.0))))
         ;; z rotation
         (setf (elt axes joy-vw-axes-index)
               (* (if mirror -1.0 1.0)
                  (* vw-scale (if (> (abs vw) vw-thresh) vw 0.0)))))
        (t nil))
      (if (or prev-base-move
              (some #'(lambda (x) (null (equal x 0))) axes)
              (some #'(lambda (x) (null (equal x 0))) buttons))
        (progn
          (send msg :header :stamp (ros::time-now))
          (send msg :axes axes)
          (send msg :buttons buttons)
          (ros::publish joy-other-topic-name msg)
          (setq prev-base-move
                (or (some #'(lambda (x) (null (equal x 0))) axes)
                    (some #'(lambda (x) (null (equal x 0))) buttons)))
          ))))
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
                    (gripper-button :trigger)
                    (base-safe-button 'rarm-trigger)
                    (base-unsafe-button 'larm-trigger)
                    (torso-up-button 'larm-trackpad)
                    (torso-down-button 'rarm-trackpad))
    (let (visualize-arm-coords)
      (cond
        ((or larm-enable rarm-enable)
         (setq visualize-arm-coords
               (send self :arm-motion-cb :head head :torso torso :safe safe-arm :mirror mirror
                     :gripper-button gripper-button)))
        ((and loop-enable base-enable)
         (if base (send self :base-cb :safe safe-base :mirror mirror
                        :safe-button base-safe-button
                        :unsafe-button base-unsafe-button
                        :torso-up-button torso-up-button
                        :torso-down-button torso-down-button)))
        (t nil))
      visualize-arm-coords))
  ;; redefine :main-loop-step for base
  (:main-loop-step (&key (head t) (torso t) (base t) (safe-arm t) (safe-base nil) (mirror nil)
                         (visualize t)
                         (enable-button :menu)
                         (gripper-button :trigger)
                         (base-safe-button 'rarm-trigger)
                         (base-unsafe-button 'larm-trigger)
                         (torso-up-button 'larm-trackpad)
                         (torso-down-button 'rarm-trackpad))
    (let (visualize-arm-coords)
      (send self :update-current-end-coords)
      (send self :enable-cb :mirror mirror :base base :button enable-button)
      (setq visualize-arm-coords
            (send self :motion-cb :head head :torso torso
                  :base base :safe-arm safe-arm :safe-base safe-base :mirror mirror
                  :gripper-button gripper-button
                  :base-safe-button base-safe-button
                  :base-unsafe-button base-unsafe-button
                  :torso-up-button torso-up-button
                  :torso-down-button torso-down-button))
      (if (and head loop-enable) (send self :head-cb))
      (if visualize (send self :visualize visualize-arm-coords)))))

(provide :robot-move-base-vr-interface)
