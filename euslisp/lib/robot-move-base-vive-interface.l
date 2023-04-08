;; -*- mode: lisp;-*-

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")
(require :robot-move-base-vr-interface "package://eus_vive/euslisp/lib/robot-move-base-vr-interface.l")
(require :robot-vive-interface "package://eus_vive/euslisp/lib/robot-vive-interface.l")


(if (not (assoc :controller-button-cb-move-base-vive-org
                (send robot-vive-interface :methods)))
  (rplaca (assoc :controller-button-cb (send robot-vive-interface :methods))
          :controller-button-cb-move-base-vive-org))


(defmethod robot-vive-interface
  ;; overwrite controller button callbacks
  (:controller-button-cb (arm msg)
    (send self :controller-button-cb-move-base-vive-org arm msg)
    (cond
      ((eq arm :larm)
       (send self :set-val 'vw
             (if (send self :get-arm-val arm :trackpad)
               (* -1 (elt (send msg :axes) 0)) 0)))
      ((eq arm :rarm)
       (send self :set-val 'vx
             (if (send self :get-arm-val arm :trackpad)
               (elt (send msg :axes) 1) 0))
       (send self :set-val 'vy
             (if (send self :get-arm-val arm :trackpad)
               (* -1 (elt (send msg :axes) 0)) 0)))
      (t nil)))
  )


(provide :robot-move-base-vive-interface)
