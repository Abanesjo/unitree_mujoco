# Introduction
## Unitree mujoco
This is a streamlined version of the unitree_mujoco repository by unitree, built and run using Docker. 

## Usage

Clone the repo with submodules:
```
git clone --recurse-submodules https://github.com/Abanesjo/unitree_mujoco
cd unitree_mujoco
```

A single Docker image ships both the Python (`simulate_python/`) and C++ (`simulate/`) simulators. Three launch scripts are provided — they share identical Docker flags and only differ in what they run inside the container:

```
./build_and_run.sh          # Build the image and drop into an interactive bash shell (no auto-launch)
./build_and_run_python.sh   # Build the image and launch the Python simulator
./build_and_run_cpp.sh      # Build the image and launch the C++ simulator
```

On first run the image build will take a while because it compiles CycloneDDS, MuJoCo, and the Unitree SDK v2 (C++) from source. Subsequent runs reuse the cached image.

You will see the below window

<p align="center">
    <img src="doc/unitree_mujoco.png">
</p>

By default the robot's pelvis is fixed mid-air.

### Configuration

Both simulators read their settings from volume-mounted config files (edits on the host take effect on the next launch, no rebuild needed):

- **Python:** `simulate_python/config.py` — robot selection, DDS domain/interface, joystick, elastic band, simulation/viewer timesteps.
- **C++:** `simulate/config.yaml` — same fields in YAML form, plus CLI overrides via `boost::program_options`.

Robot models live under `unitree_robots/` and terrain generation lives under `terrain_tool/`. Both are volume-mounted as well, so you can edit XML scenes or regenerate terrain without rebuilding the image.

## ROS Interface

**Subscribed Topics**

- /lowcmd 

**Published Topics**
- /lowstate

Please refer to the main repo for other usage guidelines. 
