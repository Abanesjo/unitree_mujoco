FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu22.04

RUN apt update && apt upgrade -y

# unitree mujoco deps
RUN apt install -y libyaml-cpp-dev libspdlog-dev libboost-all-dev libglfw3-dev 

# unitree sdk deps
RUN apt install -y wget cmake g++ build-essential libyaml-cpp-dev libeigen3-dev libspdlog-dev libfmt-dev 

# Build tools + Python + OpenGL/X11 libs
RUN apt install -y \
    git cmake g++ build-essential \
    python3 python3-pip \
    libglfw3-dev libxkbcommon-dev libxinerama-dev libxcursor-dev libxi-dev libxrandr-dev

# Build & install CycloneDDS from source (needed by unitree_sdk2_python)
COPY dependencies/cyclonedds /tmp/cyclonedds
RUN cd /tmp/cyclonedds && mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/opt/cyclonedds -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF && \
    cmake --build . --parallel $(nproc) --target install && \
    rm -rf /tmp/cyclonedds

# Install unitree_sdk2_python (editable mode, matching upstream install instructions)
COPY dependencies/unitree_sdk2_python /opt/unitree_sdk2_python
RUN CYCLONEDDS_HOME=/opt/cyclonedds pip3 install -e /opt/unitree_sdk2_python

# Install remaining Python deps
RUN pip3 install mujoco pygame

# Environment
ENV CYCLONEDDS_HOME=/opt/cyclonedds
ENV LD_LIBRARY_PATH=/opt/cyclonedds/lib

# --- C++ simulator ---

WORKDIR /workspace/unitree_mujoco

# Copy C++ sources and dependencies needed for build
COPY dependencies/mujoco dependencies/mujoco
COPY dependencies/unitree_sdk2 dependencies/unitree_sdk2
COPY simulate/src/ simulate/src/
COPY simulate/CMakeLists.txt simulate/CMakeLists.txt
RUN ln -s /workspace/unitree_mujoco/dependencies/mujoco simulate/mujoco

# Build MuJoCo from source
WORKDIR /workspace/unitree_mujoco/dependencies/mujoco/build
RUN cmake .. && make -j$(( $(nproc) / 2 )) && make install
RUN ldconfig

# Build & install Unitree SDK2 (C++)
WORKDIR /workspace/unitree_mujoco/dependencies/unitree_sdk2/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/opt/unitree_robotics && make install

# Build the C++ simulator
WORKDIR /workspace/unitree_mujoco/simulate/build
RUN cmake .. && make -j$(( $(nproc) / 2 ))

# --- Python simulator ---

WORKDIR /workspace/unitree_mujoco
COPY simulate_python/ simulate_python/

# Default to interactive shell
WORKDIR /workspace/unitree_mujoco
CMD ["/bin/bash"]
