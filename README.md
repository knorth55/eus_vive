# eus_vive

## How to start 

### PR2

```bash
steam
roslaunch eus_vive pr2_vive.launch
```

## How to use

![Vive controller](https://www.vive.com/media/filer_public/e3/da/e3daf208-4d4e-4adf-b911-22f9458ab883/guid-2d5454b7-1225-449c-b5e5-50a5ea4184d6-web.png)

| Button | Usage |
|:-:|:-:|
| 1 / Menu | Control toggle: base / arm (Default: base) |
| 3 / Stream Menu | Steam Menu |
| 8 / Grip | Not used |

### Arm mode

You can enable arm mode of right and left arm separately.

| Command | Usage |
|:-:|:-:|
| 7 / Trigger | Gripper toggle: open/close (Default: open) | 
| Controller pose | robot end effector's pose |

### Base mode

Base mode is enabled when both arms are disabled in Arm mode.

| Command | Usage |
|:-:|:-:|
| 2 / Trackpad | Torso control: right: down / left: up |
| 2 / Trackpad + 7 / Trigger (right) | Safe base control: right: x, y / left: w |
| 2 / Trackpad + 7 / Trigger (right + left) | Unsafe base control: right: x, y / left: w |
