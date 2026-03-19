FROM ubuntu:22.04

RUN apt update && apt upgrade -y

RUN apt install -y libyaml-cpp-dev libspdlog-dev libboost-all-dev libglfw3-dev wget cmake g++ build-essential libyaml-cpp-dev libeigen3-dev libspdlog-dev libfmt-dev

# Unitree Mujoco

WORKDIR /workspace/unitree_mujoco

COPY . .

# Unitree SDK

WORKDIR /workspace/unitree_mujoco/dependencies/unitree_sdk2/build

RUN cmake .. -DCMAKE_INSTALL_PREFIX=/opt/unitree_robotics && make install

WORKDIR /workspace/unitree_mujoco/simulate/build

RUN cmake .. && make -j4

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

