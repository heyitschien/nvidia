# Use the official ROS2 Humble desktop-full image
FROM osrf/ros:humble-desktop-full

# Install additional dependencies for GUI support
RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    python3-novnc \
    python3-websockify \
    xfce4 \
    xfce4-terminal \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV DISPLAY=:1
ENV RESOLUTION=1920x1080

# Create workspace directory
WORKDIR /workspace

# Copy entrypoint script
COPY ./docker/startup.sh /
RUN chmod +x /startup.sh

# Expose ports for noVNC and VNC
EXPOSE 6080
EXPOSE 5900

# Set the entrypoint
ENTRYPOINT ["/startup.sh"]