#!/usr/bin/env python

import numpy as np

import cv_bridge
from jsk_topic_tools import ConnectionBasedTransport
import rospy

from eus_vive.msg import EusViveStatusArray
from sensor_msgs.msg import Image


class EusViveStatusVisualizer(ConnectionBasedTransport):

    def __init__(self):
        super(EusViveStatusVisualizer, self).__init__()
        self.pub = self.advertise('~output/image', Image, queue_size=1)
        self.enable = {'larm': False, 'rarm': False}
        self.collision = {'larm': False, 'rarm': False}
        self.track_error = {'larm': False, 'rarm': False}
        self.hand_close = {'larm': False, 'rarm': False}
        self.bridge = cv_bridge.CvBridge()

    def subscribe(self):
        self.sub = rospy.Subscriber('~input/image', Image, self._cb)
        self.status_sub = rospy.Subscriber(
            '~input/status', EusViveStatusArray, self._status_cb)

    def unsubscribe(self):
        self.sub.unregister()
        self.status_sub.unregister()

    def _cb(self, msg):
        img = self.bridge.imgmsg_to_cv2(msg, desired_encoding="bgr8")
        H, W, C = img.shape
        img_W = int((H * 16.0 / 9.0 - W) / 2.0)
        imgs = {}
        imgs['larm'] = np.zeros((H, img_W, C), dtype=np.uint8)
        imgs['rarm'] = np.zeros((H, img_W, C), dtype=np.uint8)

        for index, arm in zip([1, 0], ['larm', 'rarm']):
            if self.enable[arm]:
                if self.collision[arm] or self.track_error[arm]:
                    # red
                    imgs[arm][:, :, 2] = 255
                else:
                    # larm: green
                    # rarm: blue
                    imgs[arm][:, :, index] = 255
                if self.hand_close[arm]:
                    # orange
                    imgs[arm][int(2.0 * H / 3.0):, :, 0] = 0
                    imgs[arm][int(2.0 * H / 3.0):, :, 1] = 165
                    imgs[arm][int(2.0 * H / 3.0):, :, 2] = 255
            else:
                # gray
                imgs[arm][:] = 127

        img = np.concatenate((imgs['rarm'], img, imgs['larm']), axis=1)
        img_msg = self.bridge.cv2_to_imgmsg(img, encoding="bgr8")
        img_msg.header = msg.header
        self.pub.publish(img_msg)

    def _status_cb(self, msg):
        for status in msg.status:
            if status.part_name in self.enable:
                self.enable[status.part_name] = status.enable
            if status.part_name in self.collision:
                self.collision[status.part_name] = status.collision
            if status.part_name in self.track_error:
                self.track_error[status.part_name] = status.track_error
            if status.part_name in self.hand_close:
                self.hand_close[status.part_name] = status.hand_close


if __name__ == '__main__':
    rospy.init_node('eus_vive_status_visualizer')
    app = EusViveStatusVisualizer()
    rospy.spin()
