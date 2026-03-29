FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu22.04

RUN apt update && apt upgrade -y

# Build tools (for CycloneDDS) + Python + OpenGL/X11 libs (for MuJoCo viewer)
RUN apt install -y \
    cmake g++ build-essential \
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

# Copy Python simulator source
WORKDIR /workspace/unitree_mujoco
COPY simulate_python/ simulate_python/

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
