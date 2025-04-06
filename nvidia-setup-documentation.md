# NVIDIA Environment Setup for Isaac Sim

## Current System Configuration

As of April 4, 2025, we have set up the following components on our Ubuntu Linux system:

### Hardware
- **GPU**: NVIDIA GeForce RTX 3070 Ti (8GB VRAM)
- **System**: Ubuntu 24.04.2 LTS (Noble)

### Software Components
- **NVIDIA Driver**: 565.57.01
- **CUDA Version**: 12.7 (system) / 12.6 (compiler tools)
- **Docker**: 26.1.3
- **NVIDIA Container Toolkit**: 1.17.5

## Setup Process Completed

### 1. Verified Current NVIDIA Configuration
```bash
# Check GPU
lspci | grep -i nvidia

# Check NVIDIA driver and CUDA version
nvidia-smi

# Check CUDA compiler version
nvcc --version
```

### 2. Docker Installation
```bash
# Update package lists
sudo apt update

# Install Docker
sudo apt install docker.io

# Add user to Docker group for permissions
sudo usermod -aG docker $USER
```

### 3. NVIDIA Container Toolkit Installation
```bash
# Add GPG key
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://nvidia.github.io/libnvidia-container/stable/deb/amd64 /" | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update package lists
sudo apt-get update

# Install NVIDIA Container Toolkit
sudo apt-get install -y nvidia-container-toolkit

# Configure Docker to use NVIDIA Container Toolkit
sudo nvidia-ctk runtime configure --runtime=docker

# Restart Docker service
sudo systemctl restart docker

# Verify installation
sudo docker run --rm --runtime=nvidia --gpus all nvidia/cuda:12.3.0-base-ubuntu22.04 nvidia-smi
```

## Isaac Sim Installation Guide

Based on the latest NVIDIA documentation, here's the recommended process for installing Isaac Sim on Ubuntu Linux:

### Prerequisites

1. **System Requirements**
   - Ubuntu 22.04 LTS or newer (our system is Ubuntu 24.04.2 LTS)
   - NVIDIA GPU with at least 8GB VRAM (our RTX 3070 Ti has 8GB)
   - Minimum 32GB RAM recommended for advanced usage
   - 40GB free disk space

2. **Driver Requirements**
   - Recommended driver version: 535.129.03 or newer (our current version 565.57.01 exceeds this)

### Installation Options

There are two main methods to install Isaac Sim:
1. **Workstation Installation** - For desktop GUI usage
2. **Container Installation** - For headless servers or cloud deployment (recommended for development)

### Container Installation (Recommended)

The container installation is recommended for developers as it provides a consistent environment and easier updates.

#### 1. Update NVIDIA Driver (if needed)
Our current driver (565.57.01) is newer than the recommended version (535.129.03), so no update is needed.

#### 2. Docker and NVIDIA Container Toolkit
We have already completed this step.

#### 3. Pull and Run Isaac Sim Container

```bash
# Create a directory for Isaac Sim data
mkdir -p ~/isaac-sim-data

# Pull the latest Isaac Sim container
docker pull nvcr.io/nvidia/isaac-sim:2023.1.1

# Run Isaac Sim container with GUI support
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

# Inside the container, run Isaac Sim
./runheadless.native.sh
```

#### 4. Alternative: Headless Mode with Web Interface

```bash
# Run Isaac Sim in headless mode with web interface
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

### Workstation Installation (Alternative)

If you prefer a native installation:

1. Download the Omniverse Launcher from the [NVIDIA Omniverse website](https://www.nvidia.com/en-us/omniverse/)
2. Install the launcher and log in with your NVIDIA developer account
3. Use the launcher to install Isaac Sim
4. Install Nucleus and Cache components when prompted

### Latest Version Information

As of April 2025, the latest version of Isaac Sim is 4.5.0. The container installation is recommended for developers as it provides better isolation and reproducibility.

## Next Steps

1. **Download and Install Isaac Sim**:
   - Choose between container or workstation installation based on your needs
   - For container installation, follow the commands in the "Container Installation" section
   - For workstation installation, download the Omniverse Launcher

2. **Set Up Development Environment**:
   - Install Python dependencies for robotics development
   - Configure IDE integration if needed

3. **Explore Isaac Sim Documentation**:
   - [Isaac Sim Documentation](https://docs.isaacsim.omniverse.nvidia.com/)
   - [Isaac Sim Tutorials](https://docs.isaacsim.omniverse.nvidia.com/latest/tutorials/index.html)
   - [Isaac Sim Python API](https://docs.isaacsim.omniverse.nvidia.com/latest/python_api/index.html)

4. **Join the NVIDIA Developer Community**:
   - [NVIDIA Developer Forums](https://forums.developer.nvidia.com/c/agx-autonomous-machines/isaac/isaac-sim/321)
   - [NVIDIA Discord Server](https://discord.gg/nvidia-omniverse)
