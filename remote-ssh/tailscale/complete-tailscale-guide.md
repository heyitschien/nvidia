# Complete Tailscale Setup and Usage Guide

This guide provides comprehensive instructions for setting up and using Tailscale to connect your macOS and Linux machines securely across different networks.

## What is Tailscale?

Tailscale is a modern VPN built on WireGuard that creates a secure, private network between your devices. Unlike traditional VPNs, Tailscale:

- Creates a mesh network where devices connect directly to each other
- Works across NATs and firewalls without port forwarding
- Provides stable private IP addresses for your devices
- Requires minimal configuration
- Enables secure access to any network service, not just SSH

## System Requirements

- **macOS**: 10.13 (High Sierra) or newer
- **Linux**: Most modern distributions (Ubuntu, Debian, Fedora, etc.)
- **Internet connection** on both machines
- **Tailscale account** (free tier available at tailscale.com)

## Setup Instructions

### Part 1: Linux Setup

1. **Install Tailscale**:
   ```bash
   # For Ubuntu/Debian
   curl -fsSL https://tailscale.com/install.sh | sh
   
   # For other distributions, see: https://tailscale.com/download/linux
   ```

2. **Start Tailscale and authenticate**:
   ```bash
   sudo tailscale up
   ```
   This will provide a URL to authenticate your device. Open the URL in a browser and sign in with your Tailscale account.

3. **Enable Tailscale to start on boot**:
   ```bash
   sudo systemctl enable tailscaled
   ```

4. **Verify Tailscale is running**:
   ```bash
   sudo systemctl status tailscaled
   tailscale status
   ```

5. **Note your Tailscale IP address**:
   ```bash
   tailscale ip
   ```
   This will show your Linux machine's Tailscale IP (e.g., 100.125.189.17)

6. **Ensure SSH server is installed and running**:
   ```bash
   # Check if SSH is installed
   which sshd
   
   # If not installed, install it
   sudo apt install openssh-server
   
   # Start and enable SSH service
   sudo systemctl start ssh
   sudo systemctl enable ssh
   
   # Check SSH status
   sudo systemctl status ssh
   ```

7. **Configure SSH for key-based authentication** (if not already done):
   ```bash
   # Create .ssh directory if it doesn't exist
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   
   # Create authorized_keys file if it doesn't exist
   touch ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   
   # Add your public key to authorized_keys
   # (You'll need to copy your public key from macOS)
   nano ~/.ssh/authorized_keys
   # Paste your public key and save (Ctrl+O, Enter, Ctrl+X)
   ```

### Part 2: macOS Setup

1. **Install Tailscale**:
   - Visit [https://tailscale.com/download/mac](https://tailscale.com/download/mac)
   - Download and install the macOS package
   - Follow the installation prompts

2. **Sign in to Tailscale**:
   - Click the Tailscale icon in the menu bar
   - Select "Sign in"
   - Authenticate with your Tailscale account (same account used for Linux)

3. **Configure Tailscale preferences**:
   - Click the Tailscale icon in the menu bar
   - Select "Preferences..."
   - Enable "Start at login" to ensure Tailscale connects automatically
   - Configure other settings as desired

4. **Create SSH key** (if you don't already have one):
   ```bash
   ssh-keygen -t ed25519
   ```
   Follow the prompts (you can press Enter for default file location and empty passphrase)

5. **Copy your public key to the Linux machine**:
   ```bash
   # View your public key
   cat ~/.ssh/id_ed25519.pub
   
   # Copy this key and add it to ~/.ssh/authorized_keys on your Linux machine
   ```

6. **Set up SSH configuration**:
   ```bash
   # Create or edit SSH config file
   nano ~/.ssh/config
   ```
   
   Add the following configuration:
   ```
   Host linux-tailscale
       HostName 100.125.189.17  # Replace with your Linux machine's Tailscale IP
       User chien               # Replace with your Linux username
       IdentityFile ~/.ssh/id_ed25519
       ServerAliveInterval 60
       ServerAliveCountMax 120
   ```
   
   Save and exit (Ctrl+O, Enter, Ctrl+X)

7. **Set proper permissions for SSH files**:
   ```bash
   chmod 600 ~/.ssh/config
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```

## Using Your Tailscale Connection

### Basic SSH Connection

From your macOS terminal, connect to your Linux machine:
```bash
ssh linux-tailscale
```

This should connect you without requiring a password.

### File Transfer with SCP

Copy files between your machines:
```bash
# Copy from macOS to Linux
scp /path/to/local/file linux-tailscale:/path/on/linux/

# Copy from Linux to macOS
scp linux-tailscale:/path/on/linux/file /path/on/macos/
```

### Syncing Directories with rsync

Sync entire directories:
```bash
# Sync from macOS to Linux
rsync -avz /path/to/local/directory/ linux-tailscale:/path/on/linux/

# Sync from Linux to macOS
rsync -avz linux-tailscale:/path/on/linux/directory/ /path/on/macos/
```

### Port Forwarding

Access services running on specific ports:
```bash
# Forward local port 8080 to port 80 on Linux
ssh -L 8080:localhost:80 linux-tailscale

# Then access the service at http://localhost:8080 on your macOS
```

## Troubleshooting

### Connection Issues

1. **Check Tailscale status on both machines**:
   ```bash
   # On macOS/Linux
   tailscale status
   ```
   Both machines should show as connected.

2. **Verify network connectivity**:
   ```bash
   # From macOS
   ping 100.125.189.17  # Replace with your Linux Tailscale IP
   ```

3. **Restart Tailscale if needed**:
   ```bash
   # On macOS
   # Click the Tailscale icon and select Disconnect, then Connect
   
   # On Linux
   sudo systemctl restart tailscaled
   ```

### SSH Issues

1. **Check SSH service on Linux**:
   ```bash
   sudo systemctl status ssh
   ```

2. **Verify SSH key permissions**:
   ```bash
   # On macOS
   ls -la ~/.ssh/
   ```
   Private keys should be 600, public keys 644.

3. **Check SSH verbose output for errors**:
   ```bash
   ssh -v linux-tailscale
   ```

## Advanced Configuration

### Enabling Exit Nodes

To route all traffic through your Linux machine:

1. **Configure Linux as an exit node**:
   ```bash
   # On Linux
   sudo tailscale up --advertise-exit-node
   ```

2. **Use Linux as an exit node from macOS**:
   - Click the Tailscale icon in the menu bar
   - Select "Use exit node"
   - Choose your Linux machine

### Sharing Specific Services

To share only specific services on your Linux machine:

1. **Enable MagicDNS in Tailscale admin console**:
   - Visit https://login.tailscale.com/admin/dns
   - Enable MagicDNS

2. **Share a specific service**:
   ```bash
   # On Linux
   sudo tailscale serve https / http://localhost:8080
   ```

## Maintenance

### Updating Tailscale

**On Linux**:
```bash
# For Ubuntu/Debian
sudo apt update
sudo apt upgrade tailscale
```

**On macOS**:
- Click the Tailscale icon in the menu bar
- Select "Check for Updates..."

### Monitoring Tailscale

**View connected devices**:
- Visit https://login.tailscale.com/admin/machines

**Check connection status**:
```bash
tailscale status
```

## Security Considerations

1. **Keep Tailscale updated** on all devices
2. **Use strong authentication** for your Tailscale account
3. **Regularly audit** connected devices in the Tailscale admin console
4. **Consider enabling 2FA** for your Tailscale account

## Additional Resources

- [Tailscale Documentation](https://tailscale.com/kb/)
- [SSH Configuration Options](https://man.openbsd.org/ssh_config.5)
- [WireGuard Protocol](https://www.wireguard.com/)
