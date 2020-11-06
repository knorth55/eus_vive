(require :baxter "package://baxtereus//baxter-util.l")


(defmethod baxter-robot
  (:reset-teleop-pose ()
    (send self :angle-vector
          (float-vector 0.0 0.0 -25 -40 70 -40 80  130
                            0.0 -25  40 70  40 80 -130))))


(provide :baxter)
