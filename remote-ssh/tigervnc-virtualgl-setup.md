# TigerVNC with VirtualGL Setup Guide

## Overview
This guide provides detailed instructions for setting up TigerVNC with VirtualGL for GPU-accelerated remote desktop access to your NVIDIA workstation. This setup complements the three-layer approach in the complete setup guide.

## Integration with Three-Layer Approach

TigerVNC with VirtualGL works alongside the three-layer approach as follows:

1. **Layer 1 (SSH)**: Used to create secure tunnels for VNC traffic
2. **Layer 2 (Tailscale)**: Provides secure network connectivity (alternative to SSH tunneling)
3. **Layer 3**: TigerVNC with VirtualGL replaces Omniverse Streaming for general desktop access

You can use both TigerVNC and Omniverse Streaming for different purposes:
- Omniverse Streaming for Isaac Sim and NVIDIA-specific applications
- TigerVNC for general desktop access and other applications

## Prerequisites

- SSH access to your NVIDIA workstation already configured
- Tailscale installed on both machines (recommended)
- NVIDIA drivers installed on the workstation
- Administrative access on both machines

## Server Setup (NVIDIA Workstation in San Jose)

### Step 1: Install Required Packages

```bash
# For Ubuntu/Debian
sudo apt update
sudo apt install -y tigervnc-standalone-server tigervnc-common xfce4 xfce4-goodies
```

### Step 2: Install VirtualGL

```bash
# Download VirtualGL (check for latest version)
wget https://sourceforge.net/projects/virtualgl/files/3.1/virtualgl_3.1_amd64.deb

# Install VirtualGL
sudo dpkg -i virtualgl_3.1_amd64.deb
sudo apt install -f
```

### Step 3: Configure VirtualGL

```bash
# Configure VirtualGL (answer questions as prompted)
sudo /opt/VirtualGL/bin/vglserver_config

# Recommended answers:
# 1. Configure server for use with VirtualGL in GLX mode? YES
# 2. Restrict 3D X server access to vglusers group? NO (unless you need this restriction)
# 3. Disable XTEST extension? NO
# 4. Install the VirtualGL faker libraries? YES
```

### Step 4: Configure VNC Server

```bash
# Set VNC password
vncpasswd

# Create VNC config directory
mkdir -p ~/.vnc

# Create xstartup file
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF

# Make xstartup executable
chmod +x ~/.vnc/xstartup

# Create VNC config file
cat > ~/.vnc/config << 'EOF'
geometry=1920x1080
depth=24
localhost
EOF
```

### Step 5: Create Systemd Service for VNC (Optional)

```bash
# Create systemd service file
sudo bash -c 'cat > /etc/systemd/system/vncserver@.service << EOF
[Unit]
Description=Remote desktop service (VNC)
After=network.target

[Service]
Type=forking
User='$USER'
Group='$USER'
WorkingDirectory=/home/'$USER'

PIDFile=/home/'$USER'/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver :%i -localhost
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1.service
```

### Step 6: Start VNC with VirtualGL Manually (Alternative to Systemd)

```bash
# Kill any existing VNC servers
vncserver -kill :1

# Start VNC with VirtualGL
DISPLAY=:0 /opt/VirtualGL/bin/vglrun vncserver :1 -localhost
```

## Client Setup (macOS M3 Ultra in Los Angeles)

### Step 1: Install TigerVNC Viewer

```bash
# Using Homebrew
brew install tiger-vnc
```

Alternatively, download from: https://sourceforge.net/projects/tigervnc/files/

### Step 2: Set Up SSH Tunnel (Option 1)

```bash
# Create SSH tunnel
ssh -L 5901:localhost:5901 username@your-workstation-ip
```

### Step 3: Connect via Tailscale (Option 2)

If you're using Tailscale (from the three-layer approach):

1. Ensure both machines are connected to Tailscale
2. Modify VNC server config to listen on Tailscale IP instead of localhost:

```bash
# On the server, edit ~/.vnc/config
# Remove or comment out the "localhost" line
```

3. Restart VNC server:

```bash
vncserver -kill :1
vncserver :1
```

4. Connect directly to the Tailscale IP:

```
tailscale-ip:5901
```

### Step 4: Connect to VNC

1. Open TigerVNC Viewer
2. Enter connection details:
   - If using SSH tunnel: `localhost:5901`
   - If using Tailscale: `tailscale-ip:5901`
3. Enter your VNC password when prompted

## Testing GPU Acceleration

To verify that GPU acceleration is working properly:

```bash
# On the VNC session, open a terminal and run:
vglrun glxinfo | grep "direct rendering"
```

You should see: `direct rendering: Yes`

To test with a 3D application:

```bash
vglrun glxgears
```

## Performance Optimization

### Optimize VNC Settings

Edit `~/.vnc/config` to adjust settings:

```
# Increase compression for better performance over slower connections
CompressLevel=9

# Use JPEG compression for better performance
JPEG=100

# Adjust geometry based on your client display
geometry=1920x1080
```

### Optimize X Server Settings

For NVIDIA GPUs, create or edit `/etc/X11/xorg.conf.d/20-nvidia.conf`:

```
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    Option "NoLogo" "true"
    Option "UseEDID" "false"
    Option "UseDisplayDevice" "none"
EndSection
```

## Troubleshooting

### Black Screen or Connection Issues

1. Check if VNC server is running:
   ```bash
   ps aux | grep vnc
   ```

2. Check VNC server logs:
   ```bash
   cat ~/.vnc/*.log
   ```

3. Verify SSH tunnel is working (if using SSH method):
   ```bash
   netstat -tuln | grep 5901
   ```

### GPU Acceleration Issues

1. Verify NVIDIA drivers are working:
   ```bash
   nvidia-smi
   ```

2. Check VirtualGL configuration:
   ```bash
   sudo /opt/VirtualGL/bin/vglserver_config -check
   ```

3. Try running applications with verbose VirtualGL output:
   ```bash
   vglrun -v glxgears
   ```

## Security Considerations

1. Always use SSH tunneling or Tailscale for secure connections
2. Set strong VNC and system passwords
3. Consider restricting VNC access to specific users with group permissions
4. Keep all software updated regularly

## Maintenance

### Regular Updates

```bash
# Update TigerVNC and VirtualGL
sudo apt update
sudo apt upgrade
```

### Backup Configuration

Backup important configuration files:

```bash
mkdir -p ~/vnc-backup
cp -r ~/.vnc ~/vnc-backup/
cp /etc/systemd/system/vncserver@.service ~/vnc-backup/
```

## Additional Resources

- [TigerVNC Official Documentation](https://tigervnc.org/)
- [VirtualGL Official Documentation](https://virtualgl.org/Documentation/Documentation)
- [NVIDIA Driver Documentation](https://docs.nvidia.com/driver-installation/index.html)
