# Tailscale VPN Setup Guide

This guide provides step-by-step instructions for setting up Tailscale VPN on both your Linux workstation in San Jose and your macOS machine in Los Angeles. Tailscale creates a secure, encrypted network between your devices, allowing them to communicate directly regardless of their physical location or network configuration.

## Benefits of Tailscale

- **Zero configuration networking**: Works across NATs and firewalls without port forwarding
- **End-to-end encryption**: All traffic between your devices is encrypted
- **MagicDNS**: Automatically assigns DNS names to your devices
- **Single sign-on**: Use your existing Google, Microsoft, or other identity provider
- **Multi-platform support**: Works on Linux, macOS, Windows, iOS, Android, etc.

## Prerequisites

- Internet connection on both machines
- Administrator/sudo access on both machines
- Email address for Tailscale account creation

## Part 1: Create a Tailscale Account

1. Visit [https://login.tailscale.com/start](https://login.tailscale.com/start)
2. Sign up using your Google, Microsoft, or email account
3. Complete the account creation process

## Part 2: Install Tailscale on Linux Workstation

### For Ubuntu/Debian-based Systems

1. Add the Tailscale package repository:
```bash
curl -fsSL https://tailscale.com/install.sh | sudo bash
```

2. Install the Tailscale package:
```bash
sudo apt-get install tailscale
```

3. Start the Tailscale service:
```bash
sudo systemctl start tailscaled
sudo systemctl enable tailscaled
```

4. Connect to your Tailscale network:
```bash
sudo tailscale up
```

5. A URL will be displayed. Open this URL in a browser and authenticate with your Tailscale account.

6. After authentication, your Linux machine will be connected to your Tailscale network.

7. Note your Tailscale IP address (you'll need this later):
```bash
tailscale ip -4
```

### For Other Linux Distributions

If you're using a different Linux distribution, refer to the official Tailscale documentation for installation instructions:
[https://tailscale.com/download/linux](https://tailscale.com/download/linux)

## Part 3: Install Tailscale on macOS

1. Download the macOS installer from [https://tailscale.com/download/mac](https://tailscale.com/download/mac)

2. Open the downloaded .pkg file and follow the installation wizard

3. Once installed, click on the Tailscale icon in your menu bar (top-right corner)

4. Click "Sign in" and authenticate with the same Tailscale account you used for your Linux machine

5. After authentication, your macOS machine will be connected to your Tailscale network

## Part 4: Verify the Connection

1. On your macOS machine, open Terminal

2. Ping your Linux machine using its Tailscale IP:
```bash
ping [Tailscale-IP-of-Linux-machine]
```

3. If the ping is successful, your Tailscale VPN is working correctly

## Part 5: Configure SSH over Tailscale

Now that Tailscale is set up, you can SSH from your macOS to your Linux machine using the Tailscale IP:

1. On your macOS machine, open Terminal

2. Connect via SSH:
```bash
ssh chien@[Tailscale-IP-of-Linux-machine]
```

3. For convenience, add an entry to your SSH config file:
```bash
nano ~/.ssh/config
```

4. Add the following configuration:
```
Host linux-tailscale
    HostName [Tailscale-IP-of-Linux-machine]
    User chien
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 120
```

5. Save and exit (Ctrl+O, Enter, Ctrl+X)

6. Now you can connect simply by typing:
```bash
ssh linux-tailscale
```

## Part 6: Additional Tailscale Features (Optional)

### Enable MagicDNS

MagicDNS allows you to use hostnames instead of IP addresses:

1. In your Tailscale admin console (https://login.tailscale.com/admin/dns):
   - Navigate to the DNS tab
   - Enable MagicDNS

2. Once enabled, you can use hostnames like:
```bash
ssh chien@linux-machine
```

### Set Up Subnet Routing (Access Other Devices on Your Network)

If you want to access other devices on your Linux machine's network from your macOS:

1. On your Linux machine:
```bash
sudo tailscale up --advertise-routes=192.168.50.0/24
```

2. In your Tailscale admin console, approve the subnet routes

### Enable Key Expiry Notifications

To avoid unexpected disconnections:

1. In your Tailscale admin console:
   - Navigate to the Machines tab
   - Select your device
   - Enable key expiry notifications

## Troubleshooting

### Connection Issues

1. Verify both devices are connected to Tailscale:
```bash
tailscale status
```

2. Check firewall settings on both machines:
```bash
# On Linux
sudo ufw status
```

3. Restart Tailscale service if needed:
```bash
# On Linux
sudo systemctl restart tailscaled
sudo tailscale up

# On macOS
# Click on Tailscale icon in menu bar > Disconnect, then Connect
```

### Performance Issues

If you experience slow connections:

1. Check your internet connection quality on both ends
2. Consider enabling Tailscale's DERP servers for improved reliability:
```bash
sudo tailscale up --exit-node=your-exit-node
```

## Security Considerations

- Tailscale uses WireGuard protocol, which is considered highly secure
- All traffic between your devices is end-to-end encrypted
- Consider enabling 2FA on your Tailscale account for additional security
- Regularly update Tailscale on all devices

## Next Steps

After setting up Tailscale:

1. Configure NVIDIA Omniverse Streaming for optimized remote desktop access
2. Set up NoMachine or TigerVNC+VirtualGL for general desktop access
3. Consider automated backups and monitoring for your Linux workstation

## Resources

- [Tailscale Documentation](https://tailscale.com/kb/)
- [Tailscale GitHub](https://github.com/tailscale/tailscale)
- [WireGuard Protocol](https://www.wireguard.com/)
