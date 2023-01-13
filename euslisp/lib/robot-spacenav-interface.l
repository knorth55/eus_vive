;; -*- mode: lisp;-*-

(ros::load-ros-manifest "sensor_msgs")

(require :robot-vr-interface "package://eus_vive/euslisp/lib/robot-vr-interface.l")


(defclass robot-spacenav-interface
  :super robot-vr-interface
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
      (let* ((controller-left-button-p
           (and (not (eq left-button prev-left-button))
                (if button-toggle left-button t))))
        (if button-toggle
          (if (> left-button-count 0)
            (progn
              (send self :set-val 'left-button-count (- left-button-count 1))
              nil)
            (progn
              (if controller-left-button-p
                (progn
                  (send self :set-val 'left-button-count left-button-wait-count)
                  (cons controller-left-button-p left-button)))))
        (if controller-left-button-p (cons controller-left-button-p left-button))))))
  (:controller-right-button-p (arm &key (button-toggle t))
    (if (eq arm control-arm)
      (let* ((controller-right-button-p
             (and (not (eq right-button prev-right-button))
                  (if button-toggle right-button t))))
        (if button-toggle
          (if (> right-button-count 0)
            (progn
              (send self :set-val 'right-button-count (- right-button-count 1))
              nil)
            (progn
              (if controller-right-button-p
                (progn
                  (send self :set-val 'right-button-count right-button-wait-count)
                  (cons controller-right-button-p right-button)))))
          (if controller-right-button-p (cons controller-right-button-p right-button))))))
  ;; :get-target-coords
  (:get-target-coords (arm &key (head t) (mirror nil))
    ;; TODO: support dual arm control
    (send self :set-reference-end-coords arm :update-robot-model t)
    (let* ((target-arm (if mirror (send self :get-opposite-arm arm) arm))
           (ref-end-coords
             (send (send self :get-arm-val target-arm :ref-end-coords)
                   :copy-worldcoords))
           target-coords)
      (if (null (equal target-arm control-arm))
        (progn
          (ros::ros-error "Unsupported control arm: ~A" target-arm)
          (return-from :get-target-coords nil)))
      (if (some #'(lambda (x) (> (abs x) 0)) spacenav-joy-axes)
        (let* ((ref-end-coords-pos (send ref-end-coords :worldpos))
               (ref-end-coords-rot (send ref-end-coords :worldrot))
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
                   (v+ ref-end-coords-pos diff-target-pos)
                   ref-end-coords-pos))
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
                   (send (send (make-coords :rot ref-end-coords-rot) :transform
                               (make-coords :rot diff-target-rot) :world)
                         :worldrot)
                   ref-end-coords-rot)))
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
