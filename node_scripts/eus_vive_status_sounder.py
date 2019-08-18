#!/usr/bin/env python

import os
import rospkg
import rospy

from jsk_topic_tools import ConnectionBasedTransport

from eus_vive.msg import EusViveStatusArray
from sound_play.msg import SoundRequest


class EusViveStatusSounder(ConnectionBasedTransport):

    def __init__(self):
        super(EusViveStatusSounder, self).__init__()
        self.pub = self.advertise('~output/sound', SoundRequest, queue_size=1)
        self.enable = {'larm': False, 'rarm': False}
        self.collision = {'larm': False, 'rarm': False}
        self.track_error = {'larm': False, 'rarm': False}
        self.timer = rospy.Timer(rospy.Duration(1.0), self._timer_cb)
        self.rospack = rospkg.RosPack()

    def subscribe(self):
        self.status_sub = rospy.Subscriber(
            '~input/status', EusViveStatusArray, self._status_cb)

    def unsubscribe(self):
        self.status_sub.unregister()

    def _timer_cb(self, event):
        larm_enable = self.enable['larm']
        larm_collision = self.collision['larm'] if larm_enable else False
        larm_track_error = self.track_error['larm'] if larm_enable else False
        rarm_enable = self.enable['rarm']
        rarm_collision = self.collision['rarm'] if rarm_enable else False
        rarm_track_error = self.track_error['rarm'] if rarm_enable else False
        # reset
        self.collision['larm'] = False
        self.track_error['larm'] = False
        self.collision['rarm'] = False
        self.track_error['rarm'] = False
        if larm_collision or rarm_collision:
            sound_msg = SoundRequest()
            sound_msg.sound = SoundRequest.PLAY_FILE
            sound_msg.command = SoundRequest.PLAY_ONCE
            sound_msg.volume = 0.7
            sound_msg.arg = os.path.join(
                self.rospack.get_path('eus_vive'), 'sounds/alert.wav')
            self.pub.publish(sound_msg)
            rospy.sleep(1.5)
            warning_msg = SoundRequest()
            warning_msg.sound = SoundRequest.SAY
            warning_msg.command = SoundRequest.PLAY_ONCE
            warning_msg.volume = 1.0
            warning_msg.arg = "collision error"
            self.pub.publish(warning_msg)
            rospy.sleep(1.0)
        elif larm_track_error or rarm_track_error:
            sound_msg = SoundRequest()
            sound_msg.sound = SoundRequest.PLAY_FILE
            sound_msg.command = SoundRequest.PLAY_ONCE
            sound_msg.volume = 1.0
            sound_msg.arg = os.path.join(
                self.rospack.get_path('eus_vive'), 'sounds/warn.wav')
            self.pub.publish(sound_msg)
            rospy.sleep(1.5)
            warning_msg = SoundRequest()
            warning_msg.sound = SoundRequest.SAY
            warning_msg.command = SoundRequest.PLAY_ONCE
            warning_msg.volume = 1.0
            warning_msg.arg = "tracking error"
            self.pub.publish(warning_msg)
            rospy.sleep(1.0)

    def _status_cb(self, msg):
        for status in msg.status:
            if status.part_name in self.enable:
                self.enable[status.part_name] = status.enable
            if status.part_name in self.collision:
                self.collision[status.part_name] = status.collision
            if status.part_name in self.track_error:
                self.track_error[status.part_name] = status.track_error


if __name__ == '__main__':
    rospy.init_node('eus_vive_status_sounder')
    app = EusViveStatusSounder()
    rospy.spin()
