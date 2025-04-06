# Isaac Sim Installation Guide for Ubuntu Linux

## Overview

This guide provides step-by-step instructions for installing NVIDIA Isaac Sim on Ubuntu Linux using the container installation method, which is recommended for developers. Isaac Sim is NVIDIA's physics-based robotics simulation platform built on the Omniverse platform.

## Prerequisites

We have already completed the following prerequisites:
- Ubuntu 24.04.2 LTS
- NVIDIA GeForce RTX 3070 Ti with 8GB VRAM
- NVIDIA Driver 565.57.01 (exceeds the recommended 535.129.03)
- CUDA 12.7
- Docker 26.1.3
- NVIDIA Container Toolkit 1.17.5

## Installation Steps

### 1. Create Data Directory

Create a directory to store Isaac Sim data, which will be mounted to the container:

```bash
mkdir -p ~/isaac-sim-data
```

### 2. Pull the Latest Isaac Sim Container

Pull the latest Isaac Sim container from NVIDIA GPU Cloud (NGC):

```bash
docker pull nvcr.io/nvidia/isaac-sim:2023.1.1
```

Note: Check the [NVIDIA NGC Catalog](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim) for the latest available version tag.

### 3. Run Isaac Sim Container with GUI Support

For development with GUI access:

```bash
docker run --name isaac-sim --entrypoint bash -it --gpus all \
  -e "ACCEPT_EULA=Y" \
  -e "DISPLAY=$DISPLAY" \
  -e "XAUTHORITY=$XAUTHORITY" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $XAUTHORITY:$XAUTHORITY \
  -v ~/isaac-sim-data:/root/.local/share/ov/data \
  -v ~/isaac-sim-data:/root/.local/share/ov/pkg \
  -v ~/isaac-sim-data:/root/.cache \
  -p 8888:8888 \
  nvcr.io/nvidia/isaac-sim:2023.1.1
```

Once inside the container, run Isaac Sim:

```bash
./runheadless.native.sh
```

### 4. Run Isaac Sim in Headless Mode with Web Interface

For headless operation with web interface access:

```bash
docker run --name isaac-sim-headless --gpus all \
  -e "ACCEPT_EULA=Y" \
  -v ~/isaac-sim-data:/root/.local/share/ov/data \
  -v ~/isaac-sim-data:/root/.local/share/ov/pkg \
  -v ~/isaac-sim-data:/root/.cache \
  -p 8888:8888 \
  -p 47995-48012:47995-48012/udp \
  -p 47995-48012:47995-48012/tcp \
  -p 49000-49007:49000-49007/udp \
  -p 49000-49007:49000-49007/tcp \
  nvcr.io/nvidia/isaac-sim:2023.1.1 \
  ./runheadless.native.sh --web
```

After running this command, you can access the Isaac Sim web interface at http://localhost:8888.

### 5. Create a Convenient Script for Running Isaac Sim

Create a script to simplify launching Isaac Sim:

```bash
#!/bin/bash
# File: ~/Desktop/meta-front-end/nvidia/isaac-sim/run-isaac-sim.sh

# Choose mode: gui or headless
MODE=${1:-gui}

if [ "$MODE" = "gui" ]; then
  docker run --name isaac-sim-gui --rm --entrypoint bash -it --gpus all \
    -e "ACCEPT_EULA=Y" \
    -e "DISPLAY=$DISPLAY" \
    -e "XAUTHORITY=$XAUTHORITY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $XAUTHORITY:$XAUTHORITY \
    -v ~/isaac-sim-data:/root/.local/share/ov/data \
    -v ~/isaac-sim-data:/root/.local/share/ov/pkg \
    -v ~/isaac-sim-data:/root/.cache \
    -p 8888:8888 \
    nvcr.io/nvidia/isaac-sim:2023.1.1 \
    ./runheadless.native.sh
elif [ "$MODE" = "headless" ]; then
  docker run --name isaac-sim-headless --rm --gpus all \
    -e "ACCEPT_EULA=Y" \
    -v ~/isaac-sim-data:/root/.local/share/ov/data \
    -v ~/isaac-sim-data:/root/.local/share/ov/pkg \
    -v ~/isaac-sim-data:/root/.cache \
    -p 8888:8888 \
    -p 47995-48012:47995-48012/udp \
    -p 47995-48012:47995-48012/tcp \
    -p 49000-49007:49000-49007/udp \
    -p 49000-49007:49000-49007/tcp \
    nvcr.io/nvidia/isaac-sim:2023.1.1 \
    ./runheadless.native.sh --web
else
  echo "Invalid mode. Use 'gui' or 'headless'"
  exit 1
fi
```

Make the script executable:

```bash
chmod +x ~/Desktop/meta-front-end/nvidia/isaac-sim/run-isaac-sim.sh
```

## Troubleshooting

### X11 Display Issues

If you encounter X11 display issues, try the following:

```bash
# Allow X server connections
xhost +local:docker

# Run the container with additional X11 settings
docker run --name isaac-sim --entrypoint bash -it --gpus all \
  -e "ACCEPT_EULA=Y" \
  -e "DISPLAY=$DISPLAY" \
  -e "XAUTHORITY=$XAUTHORITY" \
  -e "QT_X11_NO_MITSHM=1" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $XAUTHORITY:$XAUTHORITY \
  -v ~/isaac-sim-data:/root/.local/share/ov/data \
  -v ~/isaac-sim-data:/root/.local/share/ov/pkg \
  -v ~/isaac-sim-data:/root/.cache \
  -p 8888:8888 \
  nvcr.io/nvidia/isaac-sim:2023.1.1
```

### NVIDIA Driver Issues

If you encounter NVIDIA driver issues:

1. Verify driver installation:
   ```bash
   nvidia-smi
   ```

2. Check container toolkit configuration:
   ```bash
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```

3. Test GPU access in a simple container:
   ```bash
   docker run --rm --runtime=nvidia --gpus all nvidia/cuda:12.3.0-base-ubuntu22.04 nvidia-smi
   ```

## Development with Isaac Sim

### Python Development

For Python development with Isaac Sim:

1. Enter the container in interactive mode:
   ```bash
   docker run --name isaac-sim-dev --entrypoint bash -it --gpus all \
     -e "ACCEPT_EULA=Y" \
     -v ~/isaac-sim-data:/root/.local/share/ov/data \
     -v ~/isaac-sim-data:/root/.local/share/ov/pkg \
     -v ~/isaac-sim-data:/root/.cache \
     -v ~/Desktop/meta-front-end/nvidia/isaac-sim/projects:/projects \
     nvcr.io/nvidia/isaac-sim:2023.1.1
   ```

2. Run Python scripts inside the container:
   ```bash
   cd /isaac-sim
   python -m pip install -e /projects/your_project
   python /projects/your_project/your_script.py
   ```

### Jupyter Notebook Development

For Jupyter notebook development:

```bash
docker run --name isaac-sim-jupyter --gpus all \
  -e "ACCEPT_EULA=Y" \
  -v ~/isaac-sim-data:/root/.local/share/ov/data \
  -v ~/isaac-sim-data:/root/.local/share/ov/pkg \
  -v ~/isaac-sim-data:/root/.cache \
  -v ~/Desktop/meta-front-end/nvidia/isaac-sim/projects:/projects \
  -p 8888:8888 \
  nvcr.io/nvidia/isaac-sim:2023.1.1 \
  ./python.sh -m jupyter lab --ip 0.0.0.0 --port 8888 --allow-root
```

Access Jupyter Lab at http://localhost:8888.

## Resources

- [Isaac Sim Documentation](https://docs.isaacsim.omniverse.nvidia.com/)
- [Isaac Sim Python API](https://docs.isaacsim.omniverse.nvidia.com/latest/python_api/index.html)
- [NVIDIA NGC Catalog](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim)
- [NVIDIA Developer Forums](https://forums.developer.nvidia.com/c/agx-autonomous-machines/isaac/isaac-sim/321)
- [Isaac Sim GitHub Examples](https://github.com/NVIDIA-Omniverse/IsaacSim-samples)
