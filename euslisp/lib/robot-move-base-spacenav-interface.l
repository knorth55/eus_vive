;; -*- mode: lisp;-*-

(ros::roseus-add-msgs "geometry_msgs")

(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")
(require :robot-move-base-teleop-interface "package://eus_teleop/euslisp/lib/robot-move-base-teleop-interface.l")
(require :robot-spacenav-interface "package://eus_teleop/euslisp/lib/robot-spacenav-interface.l")


(if (not (assoc :spacenav-joy-axes-cb-move-base-spacenav-org
                (send robot-spacenav-interface :methods)))
  (rplaca (assoc :spacenav-joy-axes-cb (send robot-spacenav-interface :methods))
          :spacenav-joy-axes-cb-move-base-spacenav-org))


(defmethod robot-spacenav-interface
  ;; overwrite spacenav joy axes cb
  (:spacenav-joy-axes-cb (axes)
    (send self :spacenav-joy-axes-cb-move-base-spacenav-org axes)
    ;; [trans x, trans y, trans z, rot x, rot y, rot z]
    (if loop-enable
      (progn
        (send self :set-val 'vx (elt spacenav-joy-axes 0))
        (send self :set-val 'vy (elt spacenav-joy-axes 1))
        (send self :set-val 'vw (elt spacenav-joy-axes 5))
        (send self :set-val 'z-translation-up
              (> (elt spacenav-joy-axes 2) 0))
        (send self :set-val 'z-translation-down
              (< (elt spacenav-joy-axes 2) 0))
        )))
  (:get-base-safe-button (base-safe-button)
     (cond
       ((equal base-safe-button t) t)
       ((equal base-safe-button nil) nil)
       ((equal base-safe-button 'right-button)
        (if (cdr (send self :controller-right-button-p control-arm :button-toggle t))
          (setq base-safe-enable (null base-safe-enable)))
        base-safe-enable)
       ((equal base-safe-button 'left-button)
        (if (cdr (send self :controller-left-button-p control-arm :button-toggle t))
          (setq base-safe-enable (null base-safe-enable)))
        base-safe-enable)
       (t nil)))
  )


(provide :robot-move-base-spacenav-interface)
