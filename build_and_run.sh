docker build -t unitree_mujoco:v1 .
xhost +local:docker
docker run -it --rm --name unitree_mujoco --network host \
 -e DISPLAY=$DISPLAY \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 unitree_mujoco:v1
