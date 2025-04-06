# macOS Tailscale Setup Guide

This guide will walk you through setting up Tailscale on your macOS machine to connect to your Linux workstation (100.125.189.17) that we've already configured with Tailscale.

## Prerequisites
- macOS 10.13 (High Sierra) or newer
- Administrator access on your macOS
- Your Tailscale account credentials (the same account used for the Linux machine)

## Step 1: Download and Install Tailscale

1. Visit [https://tailscale.com/download/mac](https://tailscale.com/download/mac) in your web browser
2. Click the "Download" button to download the macOS installer (.pkg file)
3. Once downloaded, open the .pkg file
4. Follow the installation wizard:
   - Click "Continue" through the introduction
   - Review the license agreement and click "Continue"
   - Click "Agree" to accept the license terms
   - Click "Install" to begin installation (you may need to enter your macOS password)
   - Wait for the installation to complete
   - Click "Close" when finished

## Step 2: Sign In to Tailscale

1. After installation, Tailscale should automatically launch
   - If it doesn't, you can find it in your Applications folder or search for it using Spotlight (Cmd+Space)

2. Look for the Tailscale icon in your menu bar (top-right corner of your screen)
   - It looks like a small network/mesh icon

3. Click on the Tailscale icon and select "Sign in"

4. A browser window will open. Sign in with the same account you used for your Linux machine
   - You can use Google, Microsoft, or other identity providers if you set up your account that way

5. After signing in, authorize the device when prompted

6. Return to your desktop - Tailscale should now show as connected in the menu bar

## Step 3: Verify the Connection

1. Open Terminal (you can find it in Applications > Utilities or search for it using Spotlight)

2. Ping your Linux machine using its Tailscale IP to verify connectivity:
```bash
ping 100.125.189.17
```

3. If you receive responses, the connection is working properly

## Step 4: Set Up SSH Configuration for Easy Access

1. In Terminal, create or edit your SSH config file:
```bash
nano ~/.ssh/config
```

2. Add the following configuration (press Ctrl+O to save, Ctrl+X to exit):
```
Host linux-tailscale
    HostName 100.125.189.17
    User chien
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 120
```

3. Now you can connect to your Linux machine simply by typing:
```bash
ssh linux-tailscale
```

## Step 5: Configure Tailscale Preferences (Optional)

1. Click on the Tailscale icon in the menu bar

2. Select "Preferences..." to access settings

3. Consider enabling these useful features:
   - "Start at login" - Ensures Tailscale connects automatically when you start your Mac
   - "Connect to exit node" - If you want to route all your traffic through your Linux machine

## Troubleshooting

### Cannot Connect to Tailscale Network

1. Check your internet connection
2. Verify that Tailscale is running (check the menu bar icon)
3. Try disconnecting and reconnecting:
   - Click the Tailscale icon in the menu bar
   - Select "Disconnect"
   - Wait a few seconds
   - Select "Connect"

### SSH Connection Issues

If you can ping the Linux machine but SSH doesn't work:

1. Verify that the SSH service is running on your Linux machine:
```bash
# Run this on your Linux machine
sudo systemctl status ssh
```

2. Check that you're using the correct username and SSH key
3. Ensure your SSH key has the correct permissions:
```bash
chmod 600 ~/.ssh/id_ed25519
```

### Slow Connection

If your connection seems slow:

1. Check your internet connection quality on both ends
2. Consider using compression for SSH:
```bash
ssh -C linux-tailscale
```

## Next Steps

Now that you have Tailscale set up on both machines, you can:

1. Transfer files between machines using SCP or SFTP:
```bash
# Copy a file from macOS to Linux
scp /path/to/local/file linux-tailscale:/path/on/remote/machine

# Copy a file from Linux to macOS
scp linux-tailscale:/path/on/remote/machine /path/to/local/file
```

2. Set up remote desktop access for GUI applications
3. Configure port forwarding for specific applications

## Additional Resources

- [Tailscale Documentation](https://tailscale.com/kb/)
- [SSH Configuration Options](https://man.openbsd.org/ssh_config.5)
- [Tailscale GitHub](https://github.com/tailscale/tailscale)
