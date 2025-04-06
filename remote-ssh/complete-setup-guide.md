# Complete Remote Access Solution for NVIDIA Workstation

## Overview
This guide provides step-by-step instructions for setting up a comprehensive remote access solution to connect from your macOS M3 Ultra in Los Angeles to your NVIDIA Linux workstation in San Jose. The solution combines secure network access with optimized streaming for NVIDIA applications like Isaac Sim and Omniverse.

## Solution Architecture

Our solution consists of three layers:

1. **Basic SSH Access**: Initial secure connection and fallback option
2. **Tailscale VPN**: Secure, persistent network connection that works across NATs and firewalls
3. **NVIDIA Omniverse Streaming**: Optimized streaming protocol for NVIDIA applications

This layered approach provides:
- Redundancy (multiple ways to connect)
- Security (encrypted connections)
- Performance (optimized for NVIDIA applications)
- Ease of use (simplified connection process)

## Prerequisites

### On NVIDIA Workstation (San Jose)
- Ubuntu/Debian-based Linux distribution
- NVIDIA RTX 4070 GPU with updated drivers
- Administrator (sudo) access
- Internet connection with port 22 (SSH) accessible

### On macOS Machine (Los Angeles)
- macOS on M3 Ultra
- Administrator access
- Internet connection

## Phase 1: Basic SSH Setup

### Step 1: Install OpenSSH Server on NVIDIA Workstation

```bash
# Connect to your workstation locally or through existing means
sudo apt update
sudo apt install openssh-server
```

### Step 2: Configure SSH Server for Security

```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config
```

Add/modify these settings:
```
Port 22
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding yes
```

### Step 3: Generate SSH Key on macOS

```bash
# On your macOS machine
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Step 4: Copy SSH Key to Workstation

If you can physically access the workstation or have existing remote access:
```bash
# On your macOS machine
ssh-copy-id username@workstation-ip
```

If you need to manually add the key:
1. Display your public key on macOS:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. Copy the output
3. On the workstation, create/edit the authorized_keys file:
   ```bash
   mkdir -p ~/.ssh
   nano ~/.ssh/authorized_keys
   ```
4. Paste your public key and save

### Step 5: Restart SSH Service

```bash
# On the workstation
sudo systemctl restart sshd
```

### Step 6: Configure Port Forwarding on Router

1. Access your router's admin interface
2. Set up port forwarding for port 22 to your workstation's internal IP
3. Note your router's public IP address

### Step 7: Test SSH Connection

```bash
# On your macOS machine
ssh username@public-ip
```

## Phase 2: Tailscale VPN Setup

### Step 1: Create Tailscale Account

1. Go to https://tailscale.com/
2. Sign up for a free account (supports up to 20 devices)

### Step 2: Install Tailscale on NVIDIA Workstation

```bash
# On the workstation
curl -fsSL https://tailscale.com/install.sh | sh
```

### Step 3: Connect Workstation to Tailscale

```bash
# On the workstation
sudo tailscale up
```

This will display a URL. Open it in a browser and authenticate with your Tailscale account.

### Step 4: Enable Tailscale SSH (Optional but Recommended)

```bash
# On the workstation
sudo tailscale up --ssh
```

### Step 5: Install Tailscale on macOS

```bash
# On your macOS machine
brew install tailscale
```

Or download from https://tailscale.com/download/

### Step 6: Connect macOS to Tailscale

```bash
# On your macOS machine
sudo tailscale up
```

Authenticate with your Tailscale account when prompted.

### Step 7: Test Tailscale Connection

```bash
# On your macOS machine
ping workstation-tailscale-ip
```

The Tailscale IP can be found by running `tailscale ip` on the workstation or checking the Tailscale admin console.

### Step 8: Test Tailscale SSH

If you enabled Tailscale SSH:
```bash
# On your macOS machine
tailscale ssh username@hostname
```

Otherwise, use regular SSH with the Tailscale IP:
```bash
ssh username@workstation-tailscale-ip
```

## Phase 3: NVIDIA Omniverse Streaming Setup

### Step 1: Install NVIDIA Omniverse on Workstation

1. Download Omniverse Launcher from https://www.nvidia.com/en-us/omniverse/download/
2. Install the launcher on your workstation
3. Through the launcher, install:
   - Omniverse Nucleus
   - Omniverse Streaming Core
   - Isaac Sim (or other Omniverse applications you need)

### Step 2: Configure Omniverse Streaming

1. Open Omniverse Launcher on the workstation
2. Go to the "Streaming" tab
3. Click "Start Streaming Server"
4. Click "Settings" and configure:
   - Resolution: 1920x1080 (or match your macOS display)
   - Frame Rate: 60 FPS
   - Bitrate: 20-50 Mbps (depending on your internet connection)
   - Codec: H.265 (HEVC)
5. Set a streaming PIN or password
6. Note the streaming URL provided

### Step 3: Install Omniverse on macOS

1. Download Omniverse Launcher for macOS from https://www.nvidia.com/en-us/omniverse/download/
2. Install the launcher on your macOS machine
3. Through the launcher, install the Streaming Client application

### Step 4: Connect to Omniverse Streaming

1. Open Omniverse Launcher on your macOS machine
2. Go to the "Streaming" tab
3. Click "Launch Streaming Client"
4. Enter connection details:
   - Host: Your workstation's Tailscale IP
   - Port: 47995 (default)
   - PIN/Password: The one you configured
5. Click "Connect"

## Fallback Options

### Option 1: TigerVNC with VirtualGL

If Omniverse Streaming isn't working well for your specific applications, set up TigerVNC with VirtualGL:

#### On the Workstation:

1. Install VirtualGL and TigerVNC:
   ```bash
   sudo apt install virtualgl tigervnc-standalone-server tigervnc-common
   ```

2. Configure VirtualGL:
   ```bash
   sudo /opt/VirtualGL/bin/vglserver_config
   ```

3. Set VNC password:
   ```bash
   vncpasswd
   ```

4. Create VNC startup script:
   ```bash
   mkdir -p ~/.vnc
   nano ~/.vnc/xstartup
   ```

   Add:
   ```bash
   #!/bin/sh
   unset SESSION_MANAGER
   unset DBUS_SESSION_BUS_ADDRESS
   exec startxfce4
   ```

5. Make it executable:
   ```bash
   chmod +x ~/.vnc/xstartup
   ```

6. Start VNC with VirtualGL:
   ```bash
   vncserver -kill :1  # Kill existing server if any
   DISPLAY=:0 /opt/VirtualGL/bin/vglrun vncserver :1 -localhost
   ```

#### On macOS:

1. Install TigerVNC Viewer:
   ```bash
   brew install tiger-vnc
   ```

2. Set up SSH tunnel:
   ```bash
   ssh -L 5901:localhost:5901 username@workstation-tailscale-ip
   ```

3. Connect to VNC:
   - Open TigerVNC Viewer
   - Connect to `localhost:5901`

### Option 2: NoMachine

For a commercial solution with excellent performance:

#### On the Workstation:

1. Download NoMachine:
   ```bash
   wget https://download.nomachine.com/download/7.10/Linux/nomachine_7.10.2_1_amd64.deb
   ```

2. Install:
   ```bash
   sudo dpkg -i nomachine_7.10.2_1_amd64.deb
   ```

#### On macOS:

1. Download and install NoMachine from https://www.nomachine.com/download
2. Connect using your workstation's Tailscale IP

## Security Hardening

### SSH Hardening

1. Install Fail2ban:
   ```bash
   sudo apt install fail2ban
   sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
   sudo nano /etc/fail2ban/jail.local
   ```

2. Configure SSH section:
   ```
   [sshd]
   enabled = true
   port = ssh
   filter = sshd
   logpath = /var/log/auth.log
   maxretry = 3
   bantime = 3600
   ```

3. Restart Fail2ban:
   ```bash
   sudo systemctl restart fail2ban
   ```

### Firewall Configuration

```bash
# On the workstation
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow from 100.64.0.0/10 to any  # Tailscale IP range
sudo ufw enable
```

## Automation and Persistence

### Automatic Startup for Omniverse Streaming

Create a systemd service:

```bash
sudo nano /etc/systemd/system/omniverse-streaming.service
```

Add:
```
[Unit]
Description=NVIDIA Omniverse Streaming Service
After=network.target

[Service]
Type=simple
User=your-username
ExecStart=/path/to/omniverse/streaming/start-script.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Create the start script:
```bash
nano ~/start-omniverse-streaming.sh
```

Add (adjust paths as needed):
```bash
#!/bin/bash
/path/to/omniverse/launcher/omni.streaming.service start
```

Make it executable:
```bash
chmod +x ~/start-omniverse-streaming.sh
```

Enable the service:
```bash
sudo systemctl enable omniverse-streaming.service
sudo systemctl start omniverse-streaming.service
```

## Troubleshooting

### Connection Issues

1. **Cannot SSH to workstation**:
   - Check if SSH service is running: `systemctl status sshd`
   - Verify firewall settings: `sudo ufw status`
   - Test local SSH access first: `ssh localhost`

2. **Tailscale not connecting**:
   - Check Tailscale status: `tailscale status`
   - Verify both devices are authenticated: Check admin console
   - Restart Tailscale: `sudo systemctl restart tailscaled`

3. **Omniverse Streaming not working**:
   - Check if streaming service is running
   - Verify Tailscale connection is active
   - Check GPU status: `nvidia-smi`

### Performance Issues

1. **High latency**:
   - Test network speed between locations
   - Lower streaming resolution and bitrate
   - Try H.264 codec instead of H.265

2. **Poor image quality**:
   - Increase bitrate in Omniverse Streaming settings
   - Check network bandwidth availability

3. **Application crashes**:
   - Check system logs: `journalctl -xe`
   - Verify GPU drivers are up to date

## Maintenance

### Regular Updates

1. **System updates**:
   ```bash
   sudo apt update
   sudo apt upgrade
   ```

2. **NVIDIA driver updates**:
   ```bash
   sudo apt install --only-upgrade nvidia-driver-xxx
   ```

3. **Tailscale updates**:
   ```bash
   sudo apt install --only-upgrade tailscale
   ```

4. **Omniverse updates**:
   - Use Omniverse Launcher to update components

### Security Audits

Periodically:
1. Check SSH configuration for vulnerabilities
2. Review Tailscale device access
3. Update passwords and keys
4. Check system logs for unauthorized access attempts

## Conclusion

This complete setup provides you with:

1. **Multiple access methods**:
   - SSH for basic terminal access
   - Tailscale for secure network connectivity
   - Omniverse Streaming for optimized application access
   - VNC/NoMachine as fallback options

2. **Security at multiple layers**:
   - Key-based SSH authentication
   - Encrypted VPN tunnel
   - Firewall protection
   - Fail2ban for brute force protection

3. **Optimized performance**:
   - Direct GPU acceleration with Omniverse Streaming
   - Low-latency connection through Tailscale
   - VirtualGL support for other applications

By following this guide, you now have a robust, secure, and high-performance remote access solution for your NVIDIA workstation that is optimized for robotics AI training with Isaac Sim and Omniverse applications.
