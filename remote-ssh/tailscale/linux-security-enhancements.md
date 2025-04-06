# Linux Security Enhancements for Tailscale SSH

Now that you have Tailscale working between your macOS and Linux machines, here are recommended security enhancements for your Linux machine.

## SSH Security Improvements

### 1. Disable Password Authentication

Since you're using key-based authentication, it's safer to disable password authentication:

```bash
sudo nano /etc/ssh/sshd_config
```

Find and change these lines:
```
#PasswordAuthentication yes
```

to:
```
PasswordAuthentication no
```

Also ensure these settings are set:
```
ChallengeResponseAuthentication no
UsePAM no
```

Save and restart SSH:
```bash
sudo systemctl restart ssh
```

### 2. Install and Configure Fail2ban

Fail2ban helps protect against brute force attacks:

```bash
sudo apt install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

Find the `[sshd]` section and ensure it's enabled:
```
[sshd]
enabled = true
port = 22
maxretry = 3
bantime = 3600
```

Save and start fail2ban:
```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 3. Configure a Firewall

Set up a basic firewall with UFW:

```bash
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow in on tailscale0
sudo ufw enable
```

## Tailscale Enhancements

### 1. Restrict SSH Access to Tailscale Only

For maximum security, you can configure SSH to only listen on your Tailscale interface:

```bash
sudo nano /etc/ssh/sshd_config
```

Add this line:
```
ListenAddress 100.125.189.17
```

Save and restart SSH:
```bash
sudo systemctl restart ssh
```

### 2. Enable Tailscale SSH (Optional)

Tailscale has a built-in SSH server that provides additional security:

```bash
sudo tailscale up --ssh
```

This allows you to use Tailscale's SSH feature, which adds additional authentication.

### 3. Set Up Subnet Routing (Optional)

If you want to access other devices on your Linux machine's network from your macOS:

```bash
sudo tailscale up --advertise-routes=192.168.50.0/24
```

Then approve the subnet routes in your Tailscale admin console.

## Maintenance Tasks

### 1. Keep Your System Updated

```bash
sudo apt update
sudo apt upgrade
```

### 2. Monitor SSH Access

Check SSH login attempts:
```bash
journalctl -u ssh
```

### 3. Regularly Update Tailscale

```bash
sudo apt update
sudo apt upgrade tailscale
```

## Troubleshooting

If you encounter issues after making these changes:

1. Check SSH status:
```bash
sudo systemctl status ssh
```

2. Check Tailscale status:
```bash
tailscale status
```

3. Review logs for errors:
```bash
journalctl -u ssh
journalctl -u tailscaled
```
