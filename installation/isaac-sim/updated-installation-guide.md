# NVIDIA Isaac Sim 4.5.0 Installation Guide

## Overview

This guide provides the latest installation instructions for NVIDIA Isaac Sim 4.5.0 on Ubuntu Linux, based on the official NVIDIA documentation. Isaac Sim is NVIDIA's physics-based robotics simulation platform built on the Omniverse platform.

## Important Notes from NVIDIA Documentation

- **Deprecation Notice**: Omniverse Launcher, Nucleus Workstation, and Nucleus Cache will be deprecated and will no longer be available starting October 1, 2025.
- **Isaac Sim 4.5.0** is the last release on Omniverse Launcher.
- Nucleus Cache is replaced by [Hub Workstation Cache](https://docs.omniverse.nvidia.com/utilities/latest/cache/hub-workstation.html).
- The Live Sync feature is deprecated in Isaac Sim 4.5.0.

## System Requirements

We have already verified that our system meets the requirements:
- Ubuntu 24.04.2 LTS
- NVIDIA GeForce RTX 3070 Ti with 8GB VRAM
- NVIDIA Driver 565.57.01 (exceeds the recommended version)
- CUDA 12.7
- Docker and NVIDIA Container Toolkit (for container-based installation)

## Installation Options

Based on the latest NVIDIA documentation, there are two main approaches to install Isaac Sim 4.5.0:

1. **Standalone Installation** (Direct Download)
2. **Container-Based Installation** (Docker)

## Option 1: Standalone Installation (Recommended by NVIDIA)

The standalone installation is now the recommended approach based on the latest NVIDIA documentation.

### 1. Download Isaac Sim 4.5.0

Download the Linux standalone version from the official NVIDIA link:
- [Isaac Sim 4.5.0 for Linux](https://download.isaacsim.omniverse.nvidia.com/isaac-sim-standalone%404.5.0-rc.36%2Brelease.19112.f59b3005.gl.linux-x86_64.release.zip) (6.7 GB)

### 2. Download the Compatibility Checker (Optional but Recommended)

Before installing, you can verify your system compatibility:
- [Isaac Sim Compatibility Checker for Linux](https://download.isaacsim.omniverse.nvidia.com/isaac-sim-comp-check%404.5.0-rc.6%2Brelease.675.f1cca148.gl.linux-x86_64.release.zip) (249.8 MB)

### 3. Installation Steps

```bash
# Create installation directory
mkdir -p ~/isaac-sim

# Download Isaac Sim 4.5.0
wget -O ~/isaac-sim-4.5.0.zip https://download.isaacsim.omniverse.nvidia.com/isaac-sim-standalone%404.5.0-rc.36%2Brelease.19112.f59b3005.gl.linux-x86_64.release.zip

# Extract the package
cd ~/isaac-sim
unzip ~/isaac-sim-4.5.0.zip
rm ~/isaac-sim-4.5.0.zip

# Run Isaac Sim
cd ~/isaac-sim
./isaac-sim.sh
```

### 4. Download Assets (Optional)

Isaac Sim assets are available in three separate packs:
- [Pack 1 of 3](https://download.isaacsim.omniverse.nvidia.com/isaac-sim-assets-1%404.5.0-rc.36%2Brelease.19112.f59b3005.zip) (33.5 GB)
- [Pack 2 of 3](https://download.isaacsim.omniverse.nvidia.com/isaac-sim-assets-2%404.5.0-rc.36%2Brelease.19112.f59b3005.zip) (28.6 GB)
- [Pack 3 of 3](https://download.isaacsim.omniverse.nvidia.com/isaac-sim-assets-3%404.5.0-rc.36%2Brelease.19112.f59b3005.zip) (24.1 GB)

## Option 2: Container-Based Installation

While the standalone installation is now recommended, the container-based approach is still valid for development environments and provides better isolation.

### 1. Pull the Latest Isaac Sim Container

```bash
# Create data directory
mkdir -p ~/isaac-sim-data

# Pull the latest Isaac Sim container
docker pull nvcr.io/nvidia/isaac-sim:2023.1.1
```

Note: Check the [NVIDIA NGC Catalog](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim) for the latest available version tag.

### 2. Run Isaac Sim Container

```bash
# Run with GUI support
docker run --name isaac-sim --gpus all \
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
```

## WebRTC Streaming Client

For remote access to Isaac Sim, NVIDIA provides a WebRTC Streaming Client:
- [WebRTC Streaming Client for Linux](https://download.isaacsim.omniverse.nvidia.com/isaacsim-webrtc-streaming-client-1.0.6-linux-x64.AppImage) (214.8 MB)

## Convenience Scripts

### Standalone Installation Script

```bash
#!/bin/bash
# File: ~/Desktop/meta-front-end/nvidia/isaac-sim/install-isaac-sim.sh

# Create installation directory
mkdir -p ~/isaac-sim

# Download Isaac Sim 4.5.0
echo "Downloading Isaac Sim 4.5.0 (6.7 GB)..."
wget -O ~/isaac-sim-4.5.0.zip https://download.isaacsim.omniverse.nvidia.com/isaac-sim-standalone%404.5.0-rc.36%2Brelease.19112.f59b3005.gl.linux-x86_64.release.zip

# Extract the package
echo "Extracting Isaac Sim 4.5.0..."
cd ~/isaac-sim
unzip ~/isaac-sim-4.5.0.zip
rm ~/isaac-sim-4.5.0.zip

echo "Isaac Sim 4.5.0 has been installed to ~/isaac-sim"
echo "To run Isaac Sim, use: ~/isaac-sim/isaac-sim.sh"

# Create a desktop shortcut
echo "[Desktop Entry]
Name=Isaac Sim 4.5.0
Comment=NVIDIA Isaac Sim Robotics Simulator
Exec=$HOME/isaac-sim/isaac-sim.sh
Icon=$HOME/isaac-sim/icon.png
Terminal=false
Type=Application
Categories=Development;Education;Science;" > ~/Desktop/isaac-sim.desktop

chmod +x ~/Desktop/isaac-sim.desktop

echo "Desktop shortcut created."
```

### Run Script for Standalone Installation

```bash
#!/bin/bash
# File: ~/Desktop/meta-front-end/nvidia/isaac-sim/run-isaac-sim-standalone.sh

# Run Isaac Sim standalone
cd ~/isaac-sim
./isaac-sim.sh "$@"
```

## Troubleshooting

### Graphics Issues

If you encounter graphics-related issues:

1. Verify that your NVIDIA driver is properly installed:
   ```bash
   nvidia-smi
   ```

2. Check OpenGL support:
   ```bash
   glxinfo | grep "OpenGL version"
   ```

3. For Vulkan issues:
   ```bash
   vulkaninfo
   ```

### Permission Issues

If you encounter permission issues with the standalone installation:

```bash
# Fix permissions
chmod -R u+x ~/isaac-sim
```

## Resources

- [Isaac Sim Documentation](https://docs.isaacsim.omniverse.nvidia.com/4.5.0/)
- [Isaac Sim Python API](https://docs.isaacsim.omniverse.nvidia.com/4.5.0/python_api/index.html)
- [NVIDIA NGC Catalog](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim)
- [NVIDIA Developer Forums](https://forums.developer.nvidia.com/c/agx-autonomous-machines/isaac/isaac-sim/321)
- [Isaac Sim GitHub Examples](https://github.com/NVIDIA-Omniverse/IsaacSim-samples)
