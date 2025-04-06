#!/bin/bash
set -e

# Setup ROS 2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash"

# Execute the command passed to the docker run
exec "$@" 