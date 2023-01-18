(require :baxter "package://eus_teleop/euslisp/lib/baxter-util.l")
(require :baxter-softhand-interface "package://baxtereus/baxter-softhand-interface.l")

(if (not (find-package "EUS_TELEOP"))
  (make-package "EUS_TELEOP"))


(defun eus_teleop::baxter-init (&rest args &key (limit-in-front nil) &allow-other-keys)
  (apply 'baxter-init :allow-other-keys t args)
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
  t)


(provide :baxter-interface)
