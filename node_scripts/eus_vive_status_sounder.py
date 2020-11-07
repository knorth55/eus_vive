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
        self.prev_enable = {'larm': None, 'rarm': None}
        self.collision = {'larm': False, 'rarm': False}
        self.track_error = {'larm': False, 'rarm': False}
        self.hand_close = {'larm': False, 'rarm': False}
        self.prev_hand_close = {'larm': None, 'rarm': None}
        self.timer = rospy.Timer(rospy.Duration(0.5), self._timer_cb)
        self.rospack = rospkg.RosPack()

    def subscribe(self):
        self.status_sub = rospy.Subscriber(
            '~input/status', EusViveStatusArray, self._status_cb)

    def unsubscribe(self):
        self.status_sub.unregister()

    def _timer_cb(self, event):
        larm_enable = self.enable['larm']
        if self.prev_enable['larm'] is None:
            larm_start = False
            larm_stop = False
        else:
            larm_start = larm_enable and not self.prev_enable['larm']
            larm_stop = not larm_enable and self.prev_enable['larm']
        if self.prev_hand_close['larm'] is None:
            lhand_open = False
            lhand_close = False
        else:
            lhand_open = (not self.hand_close['larm']
                          and self.prev_hand_close['larm'])
            lhand_close = (self.hand_close['larm']
                           and not self.prev_hand_close['larm'])
        larm_collision = self.collision['larm'] if larm_enable else False
        larm_track_error = self.track_error['larm'] if larm_enable else False

        rarm_enable = self.enable['rarm']
        if self.prev_enable['rarm'] is None:
            rarm_start = False
            rarm_stop = False
        else:
            rarm_start = rarm_enable and not self.prev_enable['rarm']
            rarm_stop = not rarm_enable and self.prev_enable['rarm']
        if self.prev_hand_close['rarm'] is None:
            rhand_open = False
            rhand_close = False
        else:
            rhand_open = (not self.hand_close['rarm']
                          and self.prev_hand_close['rarm'])
            rhand_close = (self.hand_close['rarm']
                           and not self.prev_hand_close['rarm'])
        rarm_collision = self.collision['rarm'] if rarm_enable else False
        rarm_collision = self.collision['rarm'] if rarm_enable else False
        rarm_track_error = self.track_error['rarm'] if rarm_enable else False

        # reset
        self.collision['larm'] = False
        self.track_error['larm'] = False
        self.collision['rarm'] = False
        self.track_error['rarm'] = False
        self.prev_hand_close = self.hand_close.copy()
        self.prev_enable = self.enable.copy()

        # enable
        if larm_start or rarm_start:
            sound_msg = SoundRequest()
            sound_msg.sound = SoundRequest.PLAY_FILE
            sound_msg.command = SoundRequest.PLAY_ONCE
            sound_msg.volume = 0.6
            sound_msg.arg = os.path.join(
                self.rospack.get_path('eus_vive'), 'sounds/start.wav')
            self.pub.publish(sound_msg)
            rospy.sleep(1.0)
            warning_msg = SoundRequest()
            warning_msg.sound = SoundRequest.SAY
            warning_msg.command = SoundRequest.PLAY_ONCE
            warning_msg.volume = 0.6
            if larm_start and rarm_start:
                warning_msg.arg = "both arm starting"
            elif larm_start:
                warning_msg.arg = "left arm starting"
            else:
                warning_msg.arg = "right arm starting"
            self.pub.publish(warning_msg)
        elif larm_stop or rarm_stop:
            sound_msg = SoundRequest()
            sound_msg.sound = SoundRequest.PLAY_FILE
            sound_msg.command = SoundRequest.PLAY_ONCE
            sound_msg.volume = 0.6
            sound_msg.arg = os.path.join(
                self.rospack.get_path('eus_vive'), 'sounds/stop.wav')
            self.pub.publish(sound_msg)
            rospy.sleep(1.0)
            warning_msg = SoundRequest()
            warning_msg.sound = SoundRequest.SAY
            warning_msg.command = SoundRequest.PLAY_ONCE
            warning_msg.volume = 0.6
            if larm_stop and rarm_stop:
                warning_msg.arg = "both arm stopping"
            elif larm_stop:
                warning_msg.arg = "left arm stopping"
            else:
                warning_msg.arg = "right arm stopping"
            self.pub.publish(warning_msg)
        # gripper opening
        elif lhand_open or rhand_open:
            sound_msg = SoundRequest()
            sound_msg.sound = SoundRequest.PLAY_FILE
            sound_msg.command = SoundRequest.PLAY_ONCE
            sound_msg.volume = 0.6
            sound_msg.arg = os.path.join(
                self.rospack.get_path('eus_vive'), 'sounds/gripper.wav')
            self.pub.publish(sound_msg)
            rospy.sleep(1.0)
            warning_msg = SoundRequest()
            warning_msg.sound = SoundRequest.SAY
            warning_msg.command = SoundRequest.PLAY_ONCE
            warning_msg.volume = 0.6
            if lhand_open and rhand_open:
                warning_msg.arg = "both hand opening"
            elif lhand_open:
                warning_msg.arg = "left hand opening"
            else:
                warning_msg.arg = "right hand opening"
            self.pub.publish(warning_msg)
            rospy.sleep(1.0)
        # gripper closing
        elif lhand_close or rhand_close:
            sound_msg = SoundRequest()
            sound_msg.sound = SoundRequest.PLAY_FILE
            sound_msg.command = SoundRequest.PLAY_ONCE
            sound_msg.volume = 0.6
            sound_msg.arg = os.path.join(
                self.rospack.get_path('eus_vive'), 'sounds/gripper.wav')
            self.pub.publish(sound_msg)
            rospy.sleep(1.0)
            warning_msg = SoundRequest()
            warning_msg.sound = SoundRequest.SAY
            warning_msg.command = SoundRequest.PLAY_ONCE
            warning_msg.volume = 0.6
            if lhand_close and rhand_close:
                warning_msg.arg = "both hand closing"
            elif lhand_close:
                warning_msg.arg = "left hand closing"
            else:
                warning_msg.arg = "right hand closing"
            self.pub.publish(warning_msg)
            rospy.sleep(1.0)
        # collision and tracking error
        elif larm_collision or rarm_collision:
            sound_msg = SoundRequest()
            sound_msg.sound = SoundRequest.PLAY_FILE
            sound_msg.command = SoundRequest.PLAY_ONCE
            sound_msg.volume = 0.6
            sound_msg.arg = os.path.join(
                self.rospack.get_path('eus_vive'), 'sounds/alert.wav')
            self.pub.publish(sound_msg)
            rospy.sleep(1.0)
            warning_msg = SoundRequest()
            warning_msg.sound = SoundRequest.SAY
            warning_msg.command = SoundRequest.PLAY_ONCE
            warning_msg.volume = 0.6
            if larm_collision and rarm_collision:
                warning_msg.arg = "both arm collision error"
            elif larm_collision:
                warning_msg.arg = "left arm collision error"
            else:
                warning_msg.arg = "right arm collision error"
            self.pub.publish(warning_msg)
            rospy.sleep(2.0)
        elif larm_track_error or rarm_track_error:
            sound_msg = SoundRequest()
            sound_msg.sound = SoundRequest.PLAY_FILE
            sound_msg.command = SoundRequest.PLAY_ONCE
            sound_msg.volume = 0.6
            sound_msg.arg = os.path.join(
                self.rospack.get_path('eus_vive'), 'sounds/warn.wav')
            self.pub.publish(sound_msg)
            rospy.sleep(1.0)
            warning_msg = SoundRequest()
            warning_msg.sound = SoundRequest.SAY
            warning_msg.command = SoundRequest.PLAY_ONCE
            warning_msg.volume = 0.6
            if larm_track_error and rarm_track_error:
                warning_msg.arg = "both arm tracking error"
            elif larm_track_error:
                warning_msg.arg = "left arm tracking error"
            else:
                warning_msg.arg = "right arm tracking error"
            self.pub.publish(warning_msg)
            rospy.sleep(2.0)

    def _status_cb(self, msg):
        for status in msg.status:
            if status.part_name in self.enable:
                self.enable[status.part_name] = status.enable
                if self.prev_enable[status.part_name] is None:
                    self.prev_enable[status.part_name] = status.enable
            if status.part_name in self.collision:
                self.collision[status.part_name] = status.collision
            if status.part_name in self.track_error:
                self.track_error[status.part_name] = status.track_error
            if status.part_name in self.hand_close:
                self.hand_close[status.part_name] = status.hand_close
                if self.prev_hand_close[status.part_name] is None:
                    self.prev_hand_close[status.part_name] = status.hand_close


if __name__ == '__main__':
    rospy.init_node('eus_vive_status_sounder')
    app = EusViveStatusSounder()
    rospy.spin()
