FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu22.04

RUN apt update && apt upgrade -y

# unitree mujoco deps
RUN apt install -y libyaml-cpp-dev libspdlog-dev libboost-all-dev libglfw3-dev 

# unitree sdk deps
RUN apt install -y wget cmake g++ build-essential libyaml-cpp-dev libeigen3-dev libspdlog-dev libfmt-dev 

# Mujoco deps
RUN apt install -y git libxkbcommon-dev libxinerama-dev libxcursor-dev libxi-dev libxrandr-dev

# Unitree Mujoco
WORKDIR /workspace/unitree_mujoco

COPY dependencies/ dependencies/
COPY simulate/src/ simulate/src/
COPY simulate/CMakeLists.txt simulate/CMakeLists.txt
RUN ln -s /workspace/unitree_mujoco/dependencies/mujoco simulate/mujoco

WORKDIR /workspace/unitree_mujoco/dependencies/mujoco/build

RUN cmake .. && make -j$(( $(nproc) / 2 )) && make install

RUN ldconfig

# Unitree SDK

WORKDIR /workspace/unitree_mujoco/dependencies/unitree_sdk2/build

RUN cmake .. -DCMAKE_INSTALL_PREFIX=/opt/unitree_robotics && make install

WORKDIR /workspace/unitree_mujoco/simulate/build

RUN cmake .. && make -j$(( $(nproc) / 2 ))

RUN printf '#!/bin/bash\ncd /workspace/unitree_mujoco/simulate/build\nexec ./unitree_mujoco\n' > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

