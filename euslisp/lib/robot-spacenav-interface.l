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
    (send self :set-val 'spacenav-joy-axes-threshold 0.2)
    (ros::subscribe spacenav-joy-topic-name
                    sensor_msgs::Joy #'send self :spacenav-joy-cb)
    (send-super* :init args))
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
    (let ((target-coords nil))
      (if (and spacenav-joy-axes (eq arm control-arm))
        (cond
          ((or (> (abs (elt spacenav-joy-axes 0)) 0)
               (> (abs (elt spacenav-joy-axes 1)) 0)
               (> (abs (elt spacenav-joy-axes 2)) 0))
           (let* ((diff-x (* spacenav-trans-scale (elt spacenav-joy-axes 0)))
                  (diff-y (* spacenav-trans-scale (elt spacenav-joy-axes 1)))
                  (diff-z (* spacenav-trans-scale (elt spacenav-joy-axes 2)))
                  (trans-x (* (if mirror -1 1) diff-x))
                  (trans-y (* (if mirror -1 1) diff-y))
                  (trans-z diff-z))
               (send robot :angle-vector (send robot-interface :state :potentio-vector))
               (setq target-coords
                     (send (send robot control-arm :end-coords) :copy-worldcoords))
               (send target-coords :translate (float-vector trans-x trans-y trans-z) :world)))
          ;; TODO (knorth55): implement rotation
          ((or (> (abs (elt spacenav-joy-axes 3)) 0)
               (> (abs (elt spacenav-joy-axes 4)) 0)
               (> (abs (elt spacenav-joy-axes 5)) 0))
           (let* ((diff-x (* spacenav-rot-scale (elt spacenav-joy-axes 3)))
                  (diff-y (* spacenav-rot-scale (elt spacenav-joy-axes 4)))
                  (diff-z (* spacenav-rot-scale (elt spacenav-joy-axes 5)))
                  (rot-x (* (if mirror -1 1) diff-x))
                  (rot-y (* (if mirror -1 1) diff-y))
                  (rot-z diff-z))
             (send robot :angle-vector (send robot-interface :state :potentio-vector))
             (setq target-coords
                   (send (send robot control-arm :end-coords) :copy-worldcoords))
             (send target-coords :rotate rot-x :x :world)
             (send target-coords :rotate rot-y :y :world)
             (send target-coords :rotate rot-z :z :world)))
          (t nil)))
      target-coords)))


(provide :robot-spacenav-interface)
