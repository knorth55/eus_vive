#!/usr/bin/env python

from jsk_topic_tools import ConnectionBasedTransport
import rospy
from sensor_msgs.msg import CameraInfo


class VirtualCameraInfoPublisher(ConnectionBasedTransport):

    def __init__(self):
        super(VirtualCameraInfoPublisher, self).__init__()
        self.frame_id = rospy.get_param('~frame_id', None)
        self.pub = self.advertise(
            '~output/camera_info', CameraInfo, queue_size=1)

    def subscribe(self):
        self.sub = rospy.Subscriber('~input/camera_info', CameraInfo, self._cb)

    def unsubscribe(self):
        self.sub.unregister()

    def _cb(self, info_msg):
        if self.frame_id is not None:
            info_msg.header.frame_id = self.frame_id
        K = list(info_msg.K)
        P = list(info_msg.P)
        K[0] = 400.0
        K[4] = 400.0
        P[0] = 400.0
        P[5] = 400.0
        info_msg.K = K
        info_msg.P = P
        self.pub.publish(info_msg)


if __name__ == '__main__':
    rospy.init_node('virtual_camera_info_publisher')
    app = VirtualCameraInfoPublisher()
    rospy.spin()
