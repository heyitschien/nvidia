#!/bin/bash

# Exit on any error
set -e

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to cleanup on exit
cleanup() {
    log "Cleaning up..."
    if [ -f /tmp/.X1-lock ]; then
        rm /tmp/.X1-lock
    fi
    if [ -f $HOME/.vnc/*.pid ]; then
        vncserver -kill :1 || true
    fi
}

# Set cleanup trap
trap cleanup EXIT

# Create necessary directories
log "Setting up VNC environment..."
mkdir -p $HOME/.vnc

# Set up VNC password
log "Configuring VNC password..."
echo "$VNC_PASSWORD" | vncpasswd -f > $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd

# Remove old lock files if they exist
cleanup

# Start VNC server
log "Starting VNC server..."
vncserver :1 -geometry $RESOLUTION -depth 24 -localhost no

# Wait for VNC to start properly
sleep 2
if ! pgrep -x "Xtigervnc" > /dev/null; then
    log "ERROR: VNC server failed to start"
    exit 1
fi
log "VNC server started successfully"

# Start noVNC
log "Starting noVNC..."
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 6080 &
if ! pgrep -f "websockify" > /dev/null; then
    log "ERROR: noVNC failed to start"
    exit 1
fi
log "noVNC started successfully"

# Source ROS2
log "Sourcing ROS2 environment..."
source /opt/ros/humble/setup.bash

# Keep container running and show logs
log "Startup complete - container is ready"
tail -f $HOME/.vnc/*:1.log 