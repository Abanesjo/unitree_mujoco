# Introduction
## Unitree mujoco
This is a streamlined version of the unitree_mujoco repository by unitree, built and run using Docker. 

## Usage
```
./build_and_run.sh
```

You will see the below window

<p align="center">
    <img src="doc/unitree_mujoco.png">
</p>

By default the robot's pelvis is fixed mid-air.

## ROS Interface

**Subscribed Topics**

- /lowcmd 

**Published Topics**
- /lowstate

Please refer to the main repo for other usage guidelines. 