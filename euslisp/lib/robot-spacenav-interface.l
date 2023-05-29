;; -*- mode: lisp;-*-

(ros::load-ros-manifest "sensor_msgs")

(require :robot-teleop-interface "package://eus_teleop/euslisp/lib/robot-teleop-interface.l")


(defclass robot-spacenav-interface
  :super robot-teleop-interface
  :slots (spacenav-joy-topic-name
          spacenav-joy-axes
          spacenav-joy-axes-threshold
          spacenav-joy-buttons
          spacenav-trans-scale
          spacenav-rot-scale
          control-arm
          left-button
          left-button-count
          left-button-wait-count
          prev-left-button
          right-button
          right-button-count
          right-button-wait-count
          prev-right-button
          z-translation-up
          z-translation-down
          base-safe-enable
          ))


(defmethod robot-spacenav-interface
  (:init (&rest args)
    (prog1
      (send-super* :init args)
      ;; for spacenav
      (send self :set-val 'control-arm :larm)
      (send self :set-val 'left-button nil)
      (send self :set-val 'left-button-count 0)
      (send self :set-val 'prev-left-button nil)
      (send self :set-val 'right-button nil)
      (send self :set-val 'right-button-count 0)
      (send self :set-val 'prev-right-button nil)
      (send self :set-val 'spacenav-trans-scale 50)
      (send self :set-val 'spacenav-rot-scale (/ pi 16.0))
      (send self :set-val 'spacenav-joy-axes-threshold 0.2)))
  (:ros-init ()
    (prog1
      (send-super :ros-init)
      (ros::subscribe spacenav-joy-topic-name
                      sensor_msgs::Joy #'send self :spacenav-joy-cb)))
  ;; spacenav joy callbacks
  (:spacenav-joy-cb (msg)
    (send self :spacenav-joy-axes-cb (send msg :axes))
    (send self :spacenav-joy-buttons-cb (send msg :buttons)))
  ;; [trans x, trans y, trans z, rot x, rot y, rot z]
  ;; move from current coords
  (:spacenav-joy-axes-cb (axes)
    (if loop-enable
      (send self :set-val 'spacenav-joy-axes
            (mapcar #'(lambda (v) (if (> (abs v) spacenav-joy-axes-threshold) v 0))
                    (coerce axes cons)))))
  ;; [left, right]
  ;; left: grasp, right: enable
  (:spacenav-joy-buttons-cb (buttons)
    (if loop-enable
      (progn
        (send self :set-val 'prev-left-button left-button)
        (send self :set-val 'prev-right-button right-button)
        (send self :set-val 'left-button (> (elt buttons 0) 0.0))
        (send self :set-val 'right-button (> (elt buttons 1) 0.0)))))
  (:controller-left-button-p (arm &key (button-toggle t))
    (if (eq arm control-arm)
      (send self :controller-button-common-p
            'left-button :button-toggle button-toggle)))
  (:controller-right-button-p (arm &key (button-toggle t))
    (if (eq arm control-arm)
      (send self :controller-button-common-p
            'right-button :button-toggle button-toggle)))
  ;; :get-target-coords
  (:get-target-coords (arm &key (head t) (mirror nil))
    ;; TODO: support dual arm control
    (send self :update-current-end-coords)
    (let* ((target-arm (if mirror (send self :get-opposite-arm arm) arm))
           (current-end-coords
             (send (send self :get-arm-val target-arm :current-end-coords)
                   :copy-worldcoords))
           target-coords)
      (if (null (equal target-arm control-arm))
        (progn
          (ros::ros-error "Unsupported control arm: ~A" target-arm)
          (return-from :get-target-coords nil)))
      (if (some #'(lambda (x) (> (abs x) 0)) spacenav-joy-axes)
        (let* ((current-end-coords-pos (send current-end-coords :worldpos))
               (current-end-coords-rot (send current-end-coords :worldrot))
               (update-pos
                 (or (> (abs (elt spacenav-joy-axes 0)) 0)
                     (> (abs (elt spacenav-joy-axes 1)) 0)
                     (> (abs (elt spacenav-joy-axes 2)) 0)))
               (diff-target-pos
                 (if update-pos
                   (float-vector
                     (* scale spacenav-trans-scale (elt spacenav-joy-axes 0))
                     (* scale spacenav-trans-scale (elt spacenav-joy-axes 1))
                     (* scale spacenav-trans-scale (elt spacenav-joy-axes 2)))))
               (target-pos
                 (if diff-target-pos
                   (v+ current-end-coords-pos diff-target-pos)
                   current-end-coords-pos))
               (update-rot
                 (and (null update-pos)
                      (or (> (abs (elt spacenav-joy-axes 3)) 0)
                          (> (abs (elt spacenav-joy-axes 4)) 0)
                          (> (abs (elt spacenav-joy-axes 5)) 0))))
               (diff-target-rot
                 (if update-rot
                   (rpy-matrix
                     (* spacenav-rot-scale (elt spacenav-joy-axes 5))
                     (* spacenav-rot-scale (elt spacenav-joy-axes 4))
                     (* spacenav-rot-scale (elt spacenav-joy-axes 3)))))
               (target-rot
                 (if diff-target-rot
                   (send (send (make-coords :rot current-end-coords-rot) :transform
                               (make-coords :rot diff-target-rot) :world)
                         :worldrot)
                   current-end-coords-rot)))
          (if mirror
            (progn
              (setq target-pos (send self :get-mirror-pos target-pos))
              (setq target-rot (send self :get-mirror-rot target-rot))))
          (setq target-coords
                (make-coords :pos target-pos
                             :rot target-rot))))
      target-coords))
  )


(provide :robot-spacenav-interface)
