#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
docker build -t unitree_mujoco:v1 .
xhost +local:docker
docker run -it --rm --name unitree_mujoco --network host \
 --gpus all \
 --runtime=nvidia \
 -e DISPLAY=$DISPLAY \
 -e NVIDIA_DRIVER_CAPABILITIES=all \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 -v $SCRIPT_DIR/simulate_python/config.py:/workspace/unitree_mujoco/simulate_python/config.py \
 -v $SCRIPT_DIR/simulate/config.yaml:/workspace/unitree_mujoco/simulate/config.yaml \
 -v $SCRIPT_DIR/unitree_robots:/workspace/unitree_mujoco/unitree_robots \
 -v $SCRIPT_DIR/terrain_tool:/workspace/unitree_mujoco/terrain_tool \
 unitree_mujoco:v1 \
 bash -c "cd /workspace/unitree_mujoco/simulate_python && exec python3 unitree_mujoco.py"
