FROM osrf/ros:humble-desktop-full

RUN apt update && apt upgrade -y

RUN apt install -y libyaml-cpp-dev libspdlog-dev libboost-all-dev libglfw3-dev

WORKDIR /workspace/unitree_mujoco

COPY . .

WORKDIR /workspace/unitree_mujoco/simulate/build

RUN cmake .. && make -j4

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

