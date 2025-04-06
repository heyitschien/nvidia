# NVIDIA Omniverse Streaming Setup Guide

## Overview
NVIDIA Omniverse Streaming is specifically designed for remote access to NVIDIA's visualization applications like Isaac Sim and Omniverse. It provides optimized performance for GPU-accelerated content with low latency, making it ideal for robotics AI training and development work.

## Prerequisites
- NVIDIA RTX GPU (RTX 4070 in your case)
- NVIDIA Omniverse installed on your workstation
- NVIDIA GeForce Experience (for GeForce GPUs) or NVIDIA RTX Enterprise Experience (for Quadro/RTX GPUs)
- Stable internet connection with good bandwidth (at least 25 Mbps recommended)

## Server Setup (NVIDIA Workstation in San Jose)

### 1. Install NVIDIA Omniverse

#### a. Install the Omniverse Launcher
Download and install the Omniverse Launcher from [NVIDIA's website](https://www.nvidia.com/en-us/omniverse/download/).

#### b. Install Nucleus and Streaming Components
Through the Omniverse Launcher:
- Install Omniverse Nucleus
- Install Omniverse Streaming Core
- Install Isaac Sim

### 2. Configure Omniverse Streaming

#### a. Enable Streaming in Omniverse
- Open Omniverse Launcher
- Go to the "Streaming" tab
- Click "Start Streaming Server"

#### b. Configure Streaming Settings
- Click on "Settings" in the Streaming tab
- Recommended settings:
  - Resolution: 1920x1080 (or match your client display)
  - Frame Rate: 60 FPS
  - Bitrate: 20-50 Mbps (depending on your internet connection)
  - Codec: H.265 (HEVC) for better quality or H.264 for wider compatibility

#### c. Set Up Authentication
- Create a streaming PIN or password
- Note the streaming URL provided

### 3. Configure Network Access

#### a. Port Forwarding (if accessing directly over the internet)
Configure your router to forward the following ports to your workstation:
- TCP/UDP 47998-48000 (Omniverse Streaming)
- TCP 47995-47997 (Omniverse Discovery)

#### b. Alternative: Use with VPN (Recommended)
For better security, use Omniverse Streaming over a VPN connection:
- Set up Tailscale or ZeroTier as described in [vpn-setup.md](vpn-setup.md)
- Connect to your workstation using its VPN IP address

## Client Setup (Your machine in Los Angeles)

### 1. Install NVIDIA Omniverse Client

#### a. Download and Install Omniverse Launcher
Download from [NVIDIA's website](https://www.nvidia.com/en-us/omniverse/download/)

#### b. Install Streaming Client
Through the Omniverse Launcher:
- Go to "Exchange" tab
- Search for "Streaming Client"
- Install the Streaming Client application

### 2. Connect to Your Workstation

#### a. Launch Streaming Client
- Open Omniverse Launcher
- Go to the "Streaming" tab
- Click "Launch Streaming Client"

#### b. Enter Connection Details
- Enter your workstation's public IP or hostname (or VPN IP if using VPN)
- Enter the streaming port (default is 47995)
- Enter the PIN or password you configured

#### c. Connect and Start Streaming
- Click "Connect"
- Once connected, you can launch Isaac Sim or other Omniverse applications

## Optimizing Performance

### 1. Network Optimization
- Use a wired ethernet connection when possible
- Ensure QoS (Quality of Service) on your router prioritizes streaming traffic
- Consider a dedicated internet connection for streaming sessions

### 2. Client-Side Settings
- Adjust streaming quality based on your available bandwidth
- Lower resolution and bitrate if experiencing lag
- Match the aspect ratio to your display

### 3. Server-Side Optimization
- Close unnecessary applications on your workstation
- Consider creating a dedicated user account for remote sessions
- Update NVIDIA drivers to the latest version

## Advanced Configuration

### 1. Headless Operation
For running Isaac Sim without a monitor attached:

#### a. Configure Headless X Server
Install required packages:
```bash
sudo apt install xserver-xorg-video-dummy
```

Create a configuration file:
```bash
sudo nano /etc/X11/xorg.conf
```

Add the following:
```
Section "Device"
    Identifier "Dummy"
    Driver "dummy"
    VideoRam 256000
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "Dummy"
    Monitor "Monitor0"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection

Section "Monitor"
    Identifier "Monitor0"
    HorizSync 28.0-80.0
    VertRefresh 48.0-75.0
EndSection
```

#### b. Start Headless X Server
```bash
sudo X :1 -config /etc/X11/xorg.conf &
```

#### c. Run Omniverse with Display Variable
```bash
DISPLAY=:1 ./omniverse-launcher-linux
```

### 2. Persistent Sessions
To keep your Isaac Sim sessions running even after disconnecting:

#### a. Install Screen or tmux
```bash
sudo apt install screen
```
or
```bash
sudo apt install tmux
```

#### b. Start a Persistent Session
Using screen:
```bash
screen -S omniverse
export DISPLAY=:1
./path/to/isaac-sim
```

To detach: Press `Ctrl+A` then `D`
To reattach: `screen -r omniverse`

## Troubleshooting

### Connection Issues
- Verify ports are correctly forwarded
- Check firewall settings on both client and server
- Ensure NVIDIA services are running
- Test connection using simple ping or SSH before attempting streaming

### Performance Issues
- Check GPU utilization and temperature
- Reduce streaming quality settings
- Close other GPU-intensive applications
- Update NVIDIA drivers

### Black Screen or No Display
- Verify X server is running
- Check Omniverse logs for errors
- Ensure GPU is properly recognized

## Security Considerations

### 1. Use VPN for Added Security
Always use a VPN when connecting over the internet. See [vpn-setup.md](vpn-setup.md) for details.

### 2. Regular Updates
Keep all NVIDIA software updated to the latest versions.

### 3. Dedicated User Account
Create a separate user account for remote access with appropriate permissions.

## Comparison with Other Solutions

| Feature | Omniverse Streaming | VNC/RDP | SSH X11 Forwarding |
|---------|---------------------|---------|-------------------|
| Performance with 3D apps | Excellent | Fair | Poor |
| Latency | Low | Medium | High |
| Setup Complexity | Medium | Medium | Low |
| Bandwidth Requirements | High | Medium | Low |
| GPU Acceleration | Native | Limited | Very Limited |
| Security | Good (with VPN) | Good (with SSH) | Excellent |

## Additional Resources
- [NVIDIA Omniverse Documentation](https://docs.omniverse.nvidia.com/)
- [Isaac Sim Documentation](https://docs.omniverse.nvidia.com/app_isaacsim/app_isaacsim/overview.html)
- [NVIDIA Developer Forums](https://forums.developer.nvidia.com/c/omniverse/)
