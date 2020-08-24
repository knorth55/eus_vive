# eus_vive
[![Build Status](https://travis-ci.com/knorth55/eus_vive.svg?branch=master)](https://travis-ci.com/knorth55/eus_vive)

Robot remote control program with Vive/Oculus

## Tested Environment

### Build environment

- Ubuntu 16.04 + ROS Kinetic
  - NVidia driver: `396.37`
  - OpenVR: `1.3.22`
  - Steam VR: `1.6.10`
- Ubuntu 18.04 + ROS Melodic
  - NVidia driver: `390.116`
  - OpenVR: `1.3.22`
  - Steam VR: `1.6.10`

### VR Devices

- Vive
  - Arm motion tracking
  - Controller button interface
  - HMD visual interface 
  - Vibration interface
  - Sound interface
- Oculus
  - [x] Arm motion tracking
  - [ ] Controller button interface
  - [ ] HMD visual interface 
  - [ ] Vibration interface
  - [ ] Sound interface

## Installation

### Dependency installation

#### Install dependencies (for Vive)

```bash
sudo apt-get install --reinstall xserver-xorg-video-intel libgl1-mesa-glx libgl1-mesa-dri xserver-xorg-core
sudo dpkg-reconfigure xserver-xorg
```

#### Install nvidia-driver (for Vive)

```bash
# for melodic, run command below
sudo apt install nvidia-driver-390
# for kinetic, install cuda-9.2 deb (local) manually and run command below.
sudo apt install nvidia-396
```

#### Install `OpenVR`, `steam` and `steamVR` (for Vive)

Follow [here](https://github.com/knorth55/vive_ros)

#### Install kodak 4k pro camera udev (for Baxter)

```bash
sudo cp udev/99-kodak.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### ROS Workspace build

```bash
mkdir ~/ros/vive_ws/src -p
cd ~/ros/vive_ws/src
wget https://raw.githubusercontent.com/knorth55/eus_vive/master/kinetic.rosinstall -O .rosinstall
wstool up
rosdep install --ignore-src --from-path . -y -r -i
cd ~/ros/vive_ws
catkin config
catkin build
```

## How to start 

### PR2 + Vive

#### PR1040 in JSK 73B2

```bash
steam
rossetip
rossetmaster pr1040
roslaunch eus_vive pr2_73b2_vive.launch
```

#### PR1012 in JSK 610 

```bash
steam
rossetip
rossetmaster pr1012
roslaunch eus_vive pr2_610_vive.launch
```

#### Gazebo

```bash
steam
roslaunch eus_vive pr2_gazebo_vive.launch
```

### Baxter + Vive

#### Real Robot in JSK 73B2

```bash
steam
rossetip
rossetmaster baxter
roslaunch eus_vive baxter_73b2_vive.launch
```

#### Gazebo

```bash
steam
roslaunch baxter_gazebo baxter_world.launch
roslaunch eus_vive vive.launch
roslaunch eus_vive baxter_gazebo_vive.launch
```

#### Miraikan Demo 2019/08/23-24

```bash
steam
rossetip
rossetmaster baxter
roslaunch eus_vive baxter_miraikan_vive.launch
```

## How to use Vive controller

![Vive controller](https://www.vive.com/media/filer_public/e3/da/e3daf208-4d4e-4adf-b911-22f9458ab883/guid-2d5454b7-1225-449c-b5e5-50a5ea4184d6-web.png)


### PR2

| Button | Usage |
|:-:|:-:|
| 1 / Menu | Control toggle: base / arm (Default: base) |
| 3 / Stream Menu | Steam Menu |
| 8 / Grip | Not used |

#### Arm mode

You can enable arm mode of right and left arm separately.

| Command | Usage |
|:-:|:-:|
| 7 / Trigger | Gripper toggle: open/close (Default: open) | 
| Controller pose | robot end effector's pose |

#### Base mode

Base mode is enabled when both arms are disabled in Arm mode.

| Command | Usage |
|:-:|:-:|
| 2 / Trackpad | Torso control: right: down / left: up |
| 2 / Trackpad + 7 / Trigger (right) | Safe base control: right: x, y / left: w |
| 2 / Trackpad + 7 / Trigger (right + left) | Unsafe base control: right: x, y / left: w |

### Baxter

| Button | Usage |
|:-:|:-:|
| 2 / Trackpad | Control toggle: stop / arm (Default: stop) |
| 3 / Stream Menu | Steam Menu |
| 8 / Grip | Not used |

#### Arm mode

You can enable arm mode of right and left arm separately.

| Command | Usage |
|:-:|:-:|
| 7 / Trigger | Gripper toggle: open/close (Default: open) |
| Controller pose | robot end effector's pose |

## Demo

### PR2 Fridge demo
- Trial 1: https://drive.google.com/open?id=1NsNnplM9bZQi78BY5IJC7CGwROcHd_Nc
- Trial 2: https://drive.google.com/open?id=1BSpfWCgKMXQykrTQrrrhYMP5UryFPHr7
- Trial 3: https://drive.google.com/open?id=13E_h0JvgZn_RpvnEMDYGR6lNazLvFG0w

### Baxter APC demo
- Trial 1: https://drive.google.com/open?id=156y7_M6OwD9z6B4RKwZ0UPLnyHKaNKFm
- Trial 2: https://drive.google.com/open?id=1Qb0k0Uzj0pTZhNvM7VIgD6g0RC1ohqg1
- Trial 3: https://drive.google.com/open?id=10XZ_5bBKgEk_QqtONCfnXYRLKTE6rpgE
- Trial 4: https://drive.google.com/open?id=1IyVME3OggckIfDYCDwIjQmdNneWYdXWd
- Trial 5: https://drive.google.com/open?id=1jwq_UdDzgDf-UfBpAS0G0KeykvZ-gLhW

## Tips

### Baxter network configuration

Open [Field Service Menu](https://sdk.rethinkrobotics.com/wiki/Field_Service_Menu_(FSM)) and change network configuration
