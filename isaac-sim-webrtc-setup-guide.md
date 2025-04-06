# Isaac Sim WebRTC Streaming Setup Guide

This guide documents how to set up Isaac Sim WebRTC streaming from a Linux machine in San Jose to a macOS laptop in Los Angeles, connecting over different networks.

## Overview

- **Server**: Linux machine in San Jose running Isaac Sim in streaming mode
- **Client**: macOS laptop in Los Angeles running Isaac Sim WebRTC Client
- **Connection**: Tailscale VPN for secure cross-network communication
- **Port**: 8211 (default WebRTC port for Isaac Sim)

## Prerequisites

### On Linux Server (San Jose)
- NVIDIA Isaac Sim installed
- Tailscale installed and configured
- NVIDIA GPU with updated drivers

### On macOS Client (Los Angeles)
- Isaac Sim WebRTC Streaming Client installed
- Tailscale installed and configured
- Connected to internet

## Step 1: Start Isaac Sim in Streaming Mode (Linux)

1. Navigate to the Isaac Sim installation directory:
   ```bash
   cd /home/chien/Desktop/nvidia/isaac-sim-standalone@4.5.0-rc.36+release.19112.f59b3005.gl.linux-x86_64.release
   ```

2. Launch Isaac Sim in streaming mode:
   ```bash
   ./isaac-sim.streaming.sh
   ```

3. Wait for Isaac Sim to fully load. You'll see this message in the console when it's ready:
   ```
   Isaac Sim Full Streaming App is loaded.
   ```

## Step 2: Expose WebRTC Port via Tailscale (Linux)

1. Check your Tailscale IP address:
   ```bash
   tailscale ip
   ```
   Example output: `100.125.189.17`

2. Expose the WebRTC port (8211) via Tailscale:
   ```bash
   sudo tailscale serve --bg --tcp 8211 tcp://localhost:8211
   ```

3. Verify the port is exposed:
   ```bash
   sudo tailscale serve status
   ```
   You should see entries for port 8211.

## Step 3: Connect from macOS Client

1. Download and install the Isaac Sim WebRTC Streaming Client:
   - Download from: [NVIDIA Developer Site](https://developer.nvidia.com/isaac-sim)
   - Open the DMG file
   - Drag the app to your Applications folder

2. Launch the Isaac Sim WebRTC Streaming Client

3. Enter the connection details:
   - Server: `100.125.189.17` (your Linux machine's Tailscale IP)
   - Port: `8211`
   - Click "Connect"

4. Alternative connection methods:
   - Using Tailscale hostname: `chien-ms-7d31.tail5195b4.ts.net`
   - Port: `8211`

## Troubleshooting

### Connection Issues

1. Verify Tailscale is running on both machines:
   ```bash
   tailscale status
   ```

2. Check if the WebRTC port is exposed:
   ```bash
   sudo tailscale serve status
   ```

3. Verify Isaac Sim is running in streaming mode:
   ```bash
   ps aux | grep isaac-sim.streaming
   ```

4. Check for firewall issues:
   ```bash
   sudo ufw status
   ```
   Ensure port 8211 is allowed if UFW is active.

### Restart Streaming Server

If you need to restart the streaming server:

1. Kill the current streaming process:
   ```bash
   pkill -f isaac-sim.streaming
   ```

2. Restart Isaac Sim in streaming mode:
   ```bash
   cd /home/chien/Desktop/nvidia/isaac-sim-standalone@4.5.0-rc.36+release.19112.f59b3005.gl.linux-x86_64.release
   ./isaac-sim.streaming.sh
   ```

### Performance Issues

1. Check network bandwidth:
   - Recommended: 10+ Mbps upload from Linux machine
   - Recommended: 10+ Mbps download on macOS

2. Adjust streaming quality in the WebRTC client settings

3. Close other bandwidth-intensive applications

## Stopping the Service

1. To stop exposing the WebRTC port:
   ```bash
   sudo tailscale serve --tcp=8211 off
   ```

2. To stop Isaac Sim:
   ```bash
   pkill -f isaac-sim.streaming
   ```

## Advantages Over NoMachine

- **Optimized for 3D graphics**: Better performance for Isaac Sim
- **Lower latency**: WebRTC is designed for real-time communication
- **Resource efficient**: Uses less CPU on the client side
- **Purpose-built**: Specifically designed for Isaac Sim remote access

## Security Considerations

- All traffic is encrypted through Tailscale VPN
- No need to open ports on your router
- Connection is only available to devices on your Tailscale network

## Additional Resources

- [Isaac Sim Documentation](https://docs.isaacsim.omniverse.nvidia.com/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [WebRTC Troubleshooting](https://docs.isaacsim.omniverse.nvidia.com/4.5.0/installation/manual_livestream_clients.html)
