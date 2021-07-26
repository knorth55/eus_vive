(require :baxter "package://baxtereus//baxter-util.l")


(defmethod baxter-robot
  (:reset-teleop-pose ()
    (send self :angle-vector
          (float-vector 0 12 34 -122 116 162 46 -29
                          -12 34 122 116 -162 46 29))))


(provide :baxter)
