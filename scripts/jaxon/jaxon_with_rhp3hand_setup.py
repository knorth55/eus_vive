#!/usr/bin/env python

import sys

from auto_stabilizer_config.auto_stabilizer_setup \
    import AutoStabilizer_Configurator
from auto_stabilizer_config.auto_stabilizer_setup import *  # NOQA


class JAXON_WITH_RHP3HAND_Configurator(AutoStabilizer_Configurator):
    def __init__(self, *args, **kwargs):
        super(JAXON_WITH_RHP3HAND_Configurator, self).__init__(*args, **kwargs)
        self.Groups = {
            'rleg': [
                'RLEG_JOINT0',
                'RLEG_JOINT1',
                'RLEG_JOINT2',
                'RLEG_JOINT3',
                'RLEG_JOINT4',
                'RLEG_JOINT5'
            ],
            'lleg': [
                'LLEG_JOINT0',
                'LLEG_JOINT1',
                'LLEG_JOINT2',
                'LLEG_JOINT3',
                'LLEG_JOINT4',
                'LLEG_JOINT5'
            ],
            'torso': [
                'CHEST_JOINT0',
                'CHEST_JOINT1',
                'CHEST_JOINT2'
            ],
            'head': [
                'HEAD_JOINT0',
                'HEAD_JOINT1'
            ],
            'rarm': [
                'RARM_JOINT0',
                'RARM_JOINT1',
                'RARM_JOINT2',
                'RARM_JOINT3',
                'RARM_JOINT4',
                'RARM_JOINT5',
                'RARM_JOINT6',
                'RARM_JOINT7'
            ],
            'larm': [
                'LARM_JOINT0',
                'LARM_JOINT1',
                'LARM_JOINT2',
                'LARM_JOINT3',
                'LARM_JOINT4',
                'LARM_JOINT5',
                'LARM_JOINT6',
                'LARM_JOINT7'
            ],
            "right_hand": [
                "R_THUMB_JOINT0",
                "R_THUMB_JOINT1",
                "R_MIDDLE_JOINT0"
            ],
            "left_hand": [
                "L_THUMB_JOINT0",
                "L_THUMB_JOINT1",
                "L_MIDDLE_JOINT0"
            ]
        }

    def setResetPose(self):
        self.seq_svc.setJointAngles([
            -8.002327e-06, 0.000427, -0.244732, 0.676564, -0.431836, -0.000427,
            -8.669072e-06, 0.000428, -0.244735, 0.676565, -0.431834, -0.000428,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.698132, -0.349066, -0.087266, -1.39626, 0.0, 0.0, -0.349066, 0.0,
            0.698132, 0.349066, 0.087266, -1.39626, 0.0, 0.0, -0.349066
        ] + [0.0] * 6, 5.0)
        return True

    def setCollisionFreeResetPose(self):
        self.seq_svc.setJointAngles([
            0.0, 0.0, -0.349066, 0.698132, -0.349066, 0.0,
            0.0, 0.0, -0.349066, 0.698132, -0.349066, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, -0.523599, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.523599, 0.0, 0.0, 0.0, 0.0, 0.0
        ] + [0.0] * 6, 10.0)
        return True

    def setAstParametersJAXON(self):
        # ast setting
        astp = self.ast_svc.getAutoStabilizerParam()[1]
        astp.controllable_joints = self.Groups["rleg"] + self.Groups["lleg"] + self.Groups["torso"] + self.Groups["head"] + self.Groups["rarm"] +  self.Groups["larm"]  # NOQA
        # remove hand joints
        astp.dq_weight[len(self.Groups["rleg"] + self.Groups["lleg"]):len(self.Groups["rleg"] + self.Groups["lleg"] + self.Groups["torso"])] = [1e2]*len(self.Groups["torso"])  # reduce chest joint move # NOQA
        self.ast_svc.setAutoStabilizerParam(astp)
        # kf setting
        kfp = self.kf_svc.getKalmanFilterParam()[1]
        kfp.R_angle = 1000
        self.kf_svc.setKalmanFilterParam(kfp)

    def init(self):
        super(JAXON_WITH_RHP3HAND_Configurator, self).init()
        self.setAstParametersJAXON()


if __name__ == '__main__':
    from hrpsys import rtm
    rtm.nshost = "localhost"
    rtm.nsport = "15005"
    rtm.initCORBA()

    hcf = JAXON_WITH_RHP3HAND_Configurator()

    if len(sys.argv) > 1 and sys.argv[1] == "init":
        hcf.init()
