# NoMachine Setup Guide

## Overview
This guide provides detailed instructions for setting up NoMachine for high-performance remote desktop access to your NVIDIA workstation. NoMachine offers excellent performance for GPU-accelerated applications with minimal configuration.

## Integration with Three-Layer Approach

NoMachine works alongside the three-layer approach as follows:

1. **Layer 1 (SSH)**: Used for initial secure access and configuration
2. **Layer 2 (Tailscale)**: Provides secure network connectivity (recommended for NoMachine)
3. **Layer 3**: NoMachine can be used as an alternative to Omniverse Streaming for general desktop access

You can use both NoMachine and Omniverse Streaming for different purposes:
- Omniverse Streaming for Isaac Sim and NVIDIA-specific applications
- NoMachine for general desktop access and other applications

## Prerequisites

- SSH access to your NVIDIA workstation already configured
- Tailscale installed on both machines (recommended)
- NVIDIA drivers installed on the workstation
- Administrative access on both machines

## Server Setup (NVIDIA Workstation in San Jose)

### Step 1: Download NoMachine Server

```bash
# For Debian/Ubuntu (64-bit)
wget https://download.nomachine.com/download/8.9/Linux/nomachine_8.9.1_1_amd64.deb

# For RHEL/Fedora (64-bit)
# wget https://download.nomachine.com/download/8.9/Linux/nomachine_8.9.1_1_x86_64.rpm
```

Note: Check the [NoMachine download page](https://www.nomachine.com/download) for the latest version.

### Step 2: Install NoMachine Server

```bash
# For Debian/Ubuntu
sudo dpkg -i nomachine_8.9.1_1_amd64.deb

# For RHEL/Fedora
# sudo rpm -i nomachine_8.9.1_1_x86_64.rpm
```

### Step 3: Configure NoMachine Server

The default configuration works well for most users, but you can customize it:

```bash
# Edit the server configuration file
sudo nano /usr/NX/etc/server.cfg
```

Recommended settings:

```
# Enable both password and key-based authentication
AcceptedAuthenticationMethods NX-private-key,password

# Enable password authentication
EnablePasswordAuthentication 1

# Enable NX authentication
EnableNXAuthentication 1

# Set session history
SessionHistoryLimit 10

# Set idle timeout (in seconds, 0 = never)
SessionIdleTimeout 0
```

### Step 4: Configure Display Server Settings

For optimal performance with NVIDIA GPUs:

```bash
# Edit the node configuration file
sudo nano /usr/NX/etc/node.cfg
```

Recommended settings:

```
# Enable hardware-accelerated encoding
EnableHardwareEncoding 1

# Set display quality (1-9, where 9 is highest)
DisplayQuality 9

# Set UDP port range for streaming (if using through firewall)
UDPPortRange 4000:4100
```

### Step 5: Restart NoMachine Service

```bash
sudo systemctl restart nxserver
```

## Client Setup (macOS M3 Ultra in Los Angeles)

### Step 1: Download NoMachine Client

Download the macOS client from [NoMachine's website](https://www.nomachine.com/download).

### Step 2: Install NoMachine Client

1. Open the downloaded .dmg file
2. Drag NoMachine to your Applications folder
3. Open NoMachine from your Applications folder

### Step 3: Connect via Tailscale (Recommended)

If you're using Tailscale (from the three-layer approach):

1. Ensure both machines are connected to Tailscale
2. In NoMachine client, click "Add"
3. Select "Protocol: NX"
4. Enter the Tailscale IP of your workstation
5. Keep the default port (4000)
6. Give the connection a name (e.g., "NVIDIA Workstation")
7. Click "Save"
8. Select the connection and click "Connect"
9. Enter your Linux username and password when prompted

### Step 4: Connect via Direct IP (Alternative)

If not using Tailscale:

1. Set up port forwarding on your router for port 4000 to your workstation
2. Follow the same steps as above, but use your public IP address
3. Consider setting up Dynamic DNS if your public IP changes frequently

## Optimizing for NVIDIA GPU Performance

### Step 1: Configure NoMachine for GPU Acceleration

```bash
# On the workstation, edit the node configuration
sudo nano /usr/NX/etc/node.cfg
```

Add or modify:

```
# Enable hardware-accelerated encoding
EnableHardwareEncoding 1

# Set hardware encoding type (cuda for NVIDIA)
HardwareEncodingType cuda
```

### Step 2: Configure X Server for NVIDIA

Create or edit `/etc/X11/xorg.conf.d/20-nvidia.conf`:

```
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    Option "NoLogo" "true"
EndSection
```

### Step 3: Optimize NVIDIA Settings

```bash
# Run NVIDIA settings utility
nvidia-settings
```

Recommended settings:
- Set "PowerMizer" to "Prefer Maximum Performance"
- Disable desktop effects if using a lightweight desktop environment

## Advanced Features

### Setting Up Unattended Access (Optional)

To allow connection without entering credentials each time:

1. On the client (macOS):
   - Connect to the server once normally
   - Go to NoMachine settings
   - Select "Security"
   - Enable "Save connection credentials"

2. On the server (workstation):
   - Edit `/usr/NX/etc/server.cfg`
   - Set `EnableUnattendedAccess 1`
   - Restart the service: `sudo systemctl restart nxserver`

### File Sharing

NoMachine includes built-in file sharing:

1. During a session, click the NoMachine icon in the top-right corner
2. Select "Show the NoMachine menu"
3. Go to "Devices" > "File transfers"
4. You can now drag and drop files between systems

### Multi-Monitor Support

To use multiple monitors:

1. In the NoMachine client, click on the connection settings
2. Go to "Display"
3. Select "Use all monitors" or specify which monitors to use
4. Connect to the server

## Troubleshooting

### Connection Issues

1. Verify NoMachine service is running:
   ```bash
   sudo systemctl status nxserver
   ```

2. Check firewall settings:
   ```bash
   sudo ufw status
   # Allow NoMachine if blocked
   sudo ufw allow 4000/tcp
   sudo ufw allow 4000:4100/udp
   ```

3. Check NoMachine logs:
   ```bash
   cat /usr/NX/var/log/nxserver.log
   ```

### Performance Issues

1. Check GPU status:
   ```bash
   nvidia-smi
   ```

2. Verify hardware encoding is being used:
   ```bash
   cat /usr/NX/var/log/nxserver.log | grep "hardware"
   ```

3. Adjust quality settings in the client:
   - During a session, click the NoMachine icon
   - Go to "Display" > "Change the display quality"
   - Adjust based on your network conditions

### Audio Issues

1. Install PulseAudio if not already installed:
   ```bash
   sudo apt install pulseaudio
   ```

2. Restart NoMachine:
   ```bash
   sudo systemctl restart nxserver
   ```

## Security Considerations

1. Use Tailscale for an encrypted network connection
2. Set strong system passwords
3. Consider enabling two-factor authentication for your Linux user
4. Regularly update NoMachine and your operating system
5. Disable direct internet access to NoMachine port (4000) when possible

## Maintenance

### Updating NoMachine

```bash
# Download the latest version
wget https://download.nomachine.com/download/latest/linux/nomachine_latest_amd64.deb

# Install the update
sudo dpkg -i nomachine_latest_amd64.deb
```

### Backup NoMachine Configuration

```bash
mkdir -p ~/nomachine-backup
sudo cp -r /usr/NX/etc ~/nomachine-backup/
```

## Comparison with TigerVNC+VirtualGL

| Feature | NoMachine | TigerVNC+VirtualGL |
|---------|-----------|-------------------|
| Ease of Setup | Easier (fewer steps) | More complex |
| Performance | Excellent | Good |
| GPU Acceleration | Built-in | Requires VirtualGL |
| File Sharing | Built-in | Requires additional tools |
| Multi-Monitor | Built-in | Limited support |
| Licensing | Free for personal use | Fully open source |
| Resource Usage | Higher | Lower |

## Additional Resources

- [NoMachine Official Documentation](https://www.nomachine.com/documentation)
- [NoMachine Forums](https://forums.nomachine.com/)
- [NVIDIA Driver Documentation](https://docs.nvidia.com/driver-installation/index.html)

## NoMachine Remote Desktop Setup Guide

This guide provides instructions for using NoMachine to access your Linux desktop in San Jose from your macOS machine in Los Angeles through your Tailscale connection.

### Current Setup Status

- ✅ NoMachine server installed on Linux (Version 8.16.1)
- ✅ NoMachine service running on port 4000
- ✅ Tailscale connection established between machines:
  - Linux Tailscale IP: 100.125.189.17
  - macOS Tailscale IP: 100.83.80.118

### Step 1: Install NoMachine Client on macOS

1. On your macOS machine in Los Angeles, download the NoMachine client:
   - Visit [https://www.nomachine.com/download](https://www.nomachine.com/download)
   - Click on the macOS download button
   - Download and install the package

2. Run the installer and follow the prompts to complete the installation

### Step 2: Connect to Your Linux Machine

1. Launch the NoMachine client on your macOS

2. Click "Add" to create a new connection

3. Configure the connection with these settings:
   - Protocol: NX
   - Host: 100.125.189.17 (your Linux machine's Tailscale IP)
   - Port: 4000
   - Name: Linux San Jose (or any name you prefer)

4. Click "Save" to store the connection

5. Select the connection and click "Connect"

6. When prompted, enter your Linux username and password:
   - Username: chien
   - Password: (your Linux user password)

7. NoMachine will connect to your Linux desktop and display it on your macOS screen

### Step 3: Optimize NoMachine Settings (Optional)

For better performance with NVIDIA applications:

1. In the NoMachine client, before connecting:
   - Click on the connection
   - Click "Settings"
   - Go to the "Display" tab
   - Set "Display quality" to "High"
   - Enable "Use hardware-accelerated decoding when available"
   - Set "Frames per second" to 30 (or higher if your network supports it)

2. For audio settings:
   - Go to the "Audio" tab
   - Enable "Enable audio"
   - Set quality to "High"

### Troubleshooting

#### Cannot Connect to NoMachine Server

1. Verify Tailscale connection:
   ```bash
   # On macOS
   ping 100.125.189.17
   ```

2. Check if NoMachine server is running:
   ```bash
   # On Linux
   sudo systemctl status nxserver
   ```

3. Restart NoMachine server if needed:
   ```bash
   # On Linux
   sudo systemctl restart nxserver
   ```

#### Poor Performance

1. Lower display quality in NoMachine settings
2. Reduce display resolution
3. Disable desktop effects on Linux:
   - Right-click on desktop > Appearance settings
   - Disable compositing and animations

#### Black Screen or Login Issues

1. Ensure your Linux user has a desktop environment installed
2. Make sure the Linux machine isn't in sleep mode
3. Try connecting with "Create a new virtual desktop" option in NoMachine

### Auto-Login Setup (Optional)

To ensure you can always access your Linux desktop after a reboot:

1. Configure automatic login on Linux:
   ```bash
   sudo mkdir -p /etc/lightdm
   sudo nano /etc/lightdm/lightdm.conf
   ```

2. Add these lines:
   ```
   [Seat:*]
   autologin-user=chien
   autologin-user-timeout=0
   ```

3. Save and exit (Ctrl+O, Enter, Ctrl+X)

### Using Your Remote Desktop

With NoMachine, you can:

1. Use your Linux desktop as if you were sitting in front of it
2. Run NVIDIA applications like Isaac Sim with GPU acceleration
3. Transfer files between your macOS and Linux machines
4. Use multiple monitors
5. Share your clipboard between machines

### Next Steps

After confirming NoMachine works properly:

1. Set up NVIDIA Omniverse Streaming for optimized performance with NVIDIA applications
2. Configure your Linux system to automatically log in after a reboot
3. Set up backup solutions for your important data

### Security Considerations

Your NoMachine connection is secured through Tailscale's encrypted network. However:

1. Always use a strong password for your Linux user account
2. Keep NoMachine updated on both machines
3. Consider setting up NoMachine to only listen on the Tailscale interface
