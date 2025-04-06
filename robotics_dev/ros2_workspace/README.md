# ROS2 Humble Development Environment

This workspace provides a containerized ROS2 Humble development environment with GUI support via noVNC.

## Features

- ROS2 Humble desktop-full installation
- GUI support through noVNC web interface
- Pre-installed visualization tools:
  - RViz2 for 3D visualization
  - rqt for GUI development
  - Gazebo for simulation

## Quick Start

1. Build and start the container:
   ```bash
   docker compose up --build
   ```

2. Access the GUI:
   - Open your web browser and navigate to: http://localhost:6080
   - Enter the password: rosdev

## Available Tools

- **RViz2**: 3D visualization tool for ROS2
  ```bash
  rviz2
  ```

- **Gazebo**: 3D robotics simulator
  ```bash
  gazebo
  ```

- **rqt**: Framework for GUI development
  ```bash
  rqt
  ```

## Directory Structure

- `docker/`: Contains Dockerfile and startup scripts
- `src/`: ROS2 workspace source directory
- `docs/`: Documentation and guides

## Notes

- The environment uses the official OSRF ROS2 Humble desktop-full image
- GUI access is provided through noVNC
- Shared memory is configured for better performance
- The workspace directory is mounted at `/workspace` inside the container 