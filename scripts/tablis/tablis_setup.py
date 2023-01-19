#!/usr/bin/env python

import sys
import time

from hrpsys import rtm
rtm.nshost = "localhost"
rtm.nsport = "15006"
rtm.initCORBA()

from hrpsys.OpenHRP import *  # NOQA
import OpenHRP  # NOQA

from haptics_controller import *  # NOQA
from haptics_controller.SimpleHapticsControllerService_idl import *  # NOQA


def findComp(name):
    timeout_count = 0
    comp = None
    while timeout_count < 10:
        comp = rtm.findRTC(name)
        if comp is not None and comp.isActive():
            break
        print("find Comp wait for " + name)
        time.sleep(1)
        timeout_count += 1
    if comp is None:
        print("Cannot find component: %s" % name)
    return comp


class TABLIS_Configurator:
    Groups = {
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
            'CHEST_JOINT0'
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
        ]}

    rh_svc = rtm.findService(
        findComp("RobotHardware0"),
        "RobotHardwareService",
        "RobotHardwareService",
        "service0"
    )._narrow(OpenHRP.RobotHardwareService)
    seq_svc = rtm.findService(
        findComp("seq"),
        "SequencePlayerService",
        "SequencePlayerService",
        "service0"
    )._narrow(OpenHRP.SequencePlayerService)
    sh_svc = rtm.findService(
        findComp("sh"),
        "StateHolderService",
        "StateHolderService",
        "service0"
    )._narrow(OpenHRP.StateHolderService)
    hc_svc = rtm.findService(
        findComp("hc"),
        "SimpleHapticsControllerService",
        "SimpleHapticsControllerService",
        "service0"
    )._narrow(OpenHRP.SimpleHapticsControllerService)
    log_svc = findComp("log").service("service0")._narrow(
        OpenHRP.DataLoggerService)

    def servoOn(self, jname='all', tm=3):
        self.servoOff()

        c = False
        while (c != 'Y' and c != 'y'):
            c = raw_input("press 'Y' for servo ON and power ON. >> ")

        # urata system flag resetting for jaxon
        self.rh_svc.power(jname, OpenHRP.RobotHardwareService.SWITCH_ON)
        time.sleep(0.01)
        self.rh_svc.power(jname, OpenHRP.RobotHardwareService.SWITCH_OFF)
        time.sleep(0.02)

        self.rh_svc.setServoGainPercentage(jname, 0.0)
        self.rh_svc.setServoTorqueGainPercentage(jname, 100)

        # reset JointGroups
        for k, v in self.Groups.items():
            self.seq_svc.removeJointGroup(k)
        for k, v in self.Groups.items():
            self.seq_svc.waitInterpolationOfGroup(k)
        for k, v in self.Groups.items():
            self.seq_svc.addJointGroup(k, v)

        # move to idle mode for filter type RTCs
        for rtc_name in ["hc"]:
            rtc = rtm.findRTC(rtc_name)
            if rtc:
                rtc.stop()
                rtc.start()

        time.sleep(2)
        self.sh_svc.goActual()
        self.seq_svc.setBasePos([0, 0, 1.44], 0.01)
        time.sleep(0.1)
        self.rh_svc.power(jname, OpenHRP.RobotHardwareService.SWITCH_ON)
        time.sleep(0.1)
        self.rh_svc.servo(jname, OpenHRP.RobotHardwareService.SWITCH_ON)
        return True

    def servoOff(self, jname='all'):
        c = False
        while (c != 'Y' and c != 'y'):
            c = raw_input("press 'Y' for servo OFF and power OFF. >> ")

        self.rh_svc.servo('all', OpenHRP.RobotHardwareService.SWITCH_OFF)
        time.sleep(0.2)
        if jname == 'all':
            self.rh_svc.power('all', OpenHRP.RobotHardwareService.SWITCH_OFF)
        return True

    def setHcParametersJAXON(self):
        # ast setting
        hcp = self.hc_svc.getHapticsControllerParam()[1]
        hcp.max_torque = [
            20, 80, 80, 80, 20, 20,
            20, 80, 80, 80, 20, 20,
            40,
            30, 30, 20, 20, 12, 8, 8, 6,
            30, 30, 20, 20, 12, 8, 8, 6
        ]
        hcp.qref_dgain = 10.0  # simulator only
        self.hc_svc.setHapticsControllerParam(hcp)

    def setupLogger(self):
        self.log_svc.add("TimedDoubleSeq", "RobotHardware0_q")
        rtm.connectPorts(
            rtm.findRTC("RobotHardware0").port("q"),
            rtm.findRTC("log").port("RobotHardware0_q")
        )
        self.log_svc.add("TimedDoubleSeq", "RobotHardware0_dq")
        rtm.connectPorts(
            rtm.findRTC("RobotHardware0").port("dq"),
            rtm.findRTC("log").port("RobotHardware0_dq")
        )
        self.log_svc.add("TimedDoubleSeq", "RobotHardware0_tau")
        rtm.connectPorts(
            rtm.findRTC("RobotHardware0").port("tau"),
            rtm.findRTC("log").port("RobotHardware0_tau")
        )
        self.log_svc.add("TimedLongSeqSeq", "RobotHardware0_servoState")
        rtm.connectPorts(
            rtm.findRTC("RobotHardware0").port("servoState"),
            rtm.findRTC("log").port("RobotHardware0_servoState")
        )
        self.log_svc.add("TimedDoubleSeq", "hc_genTauOut")
        rtm.connectPorts(
            rtm.findRTC("hc").port("genTauOut"),
            rtm.findRTC("log").port("hc_genTauOut")
        )
        for ee in ["rleg", "lleg", "rarm", "larm", "relbow", "lelbow"]:
            self.log_svc.add("TimedPose3D", "hc_act" + ee + "PoseOut")
            rtm.connectPorts(
                rtm.findRTC("hc").port("act" + ee + "PoseOut"),
                rtm.findRTC("log").port("hc_act" + ee + "PoseOut")
            )
        self.log_svc.maxLength(1000 * 60)
        self.log_svc.clear()

    def init(self):
        for j in self.Groups["rleg"] + self.Groups["lleg"] \
                + self.Groups["torso"] + self.Groups["rarm"] \
                + self.Groups["larm"]:
            self.rh_svc.setJointControlMode(
                j, OpenHRP.RobotHardwareService.TORQUE)
            self.rh_svc.setServoErrorLimit(j, 0.0)
            self.rh_svc.setServoTorqueGainPercentage(j, 100)
            self.rh_svc.setServoGainPercentage(j, 0.0)

        self.setupLogger()
        self.seq_svc.setBasePos([0, 0, 1.44], 2.0)
        self.setHcParametersJAXON()


if __name__ == '__main__':
    hcf = TABLIS_Configurator()

    if len(sys.argv) > 1 and sys.argv[1] == "init":
        hcf.init()
