# Troubleshooting Guide 🔧

This guide helps you resolve common issues encountered during installation and configuration of the NixOS setup.

## 📋 Table of Contents

1. [Installation Issues](#-installation-issues)
2. [Hardware Detection Problems](#-hardware-detection-problems)
3. [Rebuild Failures](#-rebuild-failures)
4. [Dotfiles Issues](#-dotfiles-issues)
5. [Disk Configuration Problems](#-disk-configuration-problems)
6. [Network and Download Issues](#-network-and-download-issues)
7. [Permission and Access Issues](#-permission-and-access-issues)
8. [Service Management Issues](#-service-management-issues)
9. [Rollback and Recovery Procedures](#-rollback-and-recovery-procedures)
10. [Advanced Debugging](#-advanced-debugging)

## 🚀 Installation Issues

### **Script Won't Start**

#### Problem: "Permission denied" when running `./install.sh`
```bash
bash: ./install.sh: Permission denied
```

**Solution:**
```bash
chmod +x install.sh
./install.sh
```

#### Problem: "This script must be run on NixOS!"
**Causes:**
- Running on non-NixOS system
- Missing `/etc/NIXOS` file

**Solutions:**
1. Ensure you're running on NixOS
2. If on NixOS but file missing:
   ```bash
   sudo touch /etc/NIXOS
   ```

#### Problem: Missing dependencies
```bash
❌ Missing dependencies: git, curl, base64
```

**Solution:**
```bash
# Install missing dependencies
nix-shell -p git curl coreutils
# Then run the installer
./install.sh
```

#### Problem: Security check failures
**Symptoms:** Installer exits during security validation

**Common Issues:**
1. **Running as root:**
   ```bash
   ❌ ERROR: Do not run this installer as root!
   ```
   **Solution:** Run as normal user: `./install.sh`

2. **No internet connection:**
   ```bash
   ❌ ERROR: No internet connection
   ```
   **Solution:** Check network connectivity and DNS

3. **Invalid execution location:**
   ```bash
   ❌ ERROR: Do not run this script inside /etc/nixos!
   ```
   **Solution:** Run from home directory or Downloads

### **Configuration Collection Fails**

#### Problem: Invalid GPU detection
**Symptoms:** Script detects wrong GPU or fails to detect

**Solutions:**
1. **Manual Override:** Choose different GPU type when prompted
2. **Check Hardware:**
   ```bash
   lspci | grep -i vga
   lshw -c display
   ```
3. **Force Detection:**
   ```bash
   # Edit variables.nix manually after installation
   sudo nano /etc/nixos/config/variables.nix
   ```

#### Problem: Hostname/Username validation fails
**Symptoms:** Script rejects valid hostnames or usernames

**Solutions:**
1. **Use Simple Names:** Avoid special characters, use alphanumeric only
2. **Check Length:** Keep under 63 characters
3. **Valid Examples:**
   - ✅ `jake`, `martinez`, `desktop-01`
   - ❌ `user@domain`, `desktop_with_spaces`, `123numeric`

## 🔧 Hardware Detection Problems

### **GPU Issues**

#### Problem: NVIDIA drivers not loading after installation
**Symptoms:**
- Black screen after reboot
- `nvidia-smi` not found
- Graphics performance issues

**Solutions:**
1. **Check Configuration:**
   ```bash
   cat /etc/nixos/config/variables.nix | grep -A 5 gpu
   ```

2. **Verify Installation:**
   ```bash
   lsmod | grep nvidia
   systemctl status display-manager
   ```

3. **Manual Fix:**
   ```bash
   # Edit variables.nix
   sudo nano /etc/nixos/config/variables.nix
   
   # Set correct GPU type
   gpu = {
     type = "nvidia";  # or "amd" or "intel"
     nvidia.enable = true;
   };
   
   # Rebuild
   sudo nixos-rebuild switch --flake /etc/nixos#default
   ```

#### Problem: AMD GPU performance issues
**Symptoms:**
- Poor graphics performance
- Games running slowly
- Driver errors in logs

**Solutions:**
1. **Enable Gaming Mode:**
   ```bash
   gaming-mode-on
   ```

2. **Check Driver Loading:**
   ```bash
   lsmod | grep amdgpu
   dmesg | grep amdgpu
   ```

3. **Update Configuration:**
   ```bash
   # Ensure AMD drivers are properly configured
   sudo nano /etc/nixos/config/variables.nix
   ```

### **Disk Detection Issues**

#### Problem: Additional disks not detected
**Symptoms:** Script shows "No additional disks detected"

**Solutions:**
1. **Check Disk Status:**
   ```bash
   lsblk -f
   sudo fdisk -l
   ```

2. **Run with Higher Privileges:**
   ```bash
   sudo ./install.sh
   ```

3. **Manual Disk Configuration:**
   ```bash
   # Find your disk UUID
   blkid /dev/sdb1
   
   # Edit variables.nix after installation
   sudo nano /etc/nixos/config/variables.nix
   ```

#### Problem: Mount point conflicts
**Symptoms:** Disk mounting fails with "target is busy"

**Solutions:**
1. **Check Current Mounts:**
   ```bash
   mount | grep /mnt
   findmnt /mnt/yourdisk
   ```

2. **Unmount Before Reconfiguration:**
   ```bash
   sudo umount /mnt/yourdisk
   sudo nixos-rebuild switch --flake /etc/nixos#default
   ```

## 🔄 Rebuild Failures

### **Common Rebuild Errors**

#### Problem: "evaluation aborted with the following error message"
**Symptoms:** Nix evaluation fails during rebuild

**Solutions:**
1. **Check Syntax:**
   ```bash
   # Validate Nix syntax
   nix-instantiate --parse /etc/nixos/config/variables.nix
   ```

2. **Check Brackets and Semicolons:**
   ```bash
   # Common issues: missing semicolons, unmatched brackets
   sudo nano /etc/nixos/config/variables.nix
   ```

3. **Restore from Backup:**
   ```bash
   sudo nixos-rebuild --rollback
   ```

#### Problem: "file 'nixpkgs' was not found"
**Symptoms:** Flake input issues

**Solutions:**
1. **Update Flake Lock:**
   ```bash
   cd /etc/nixos
   sudo nix flake update
   sudo nixos-rebuild switch --flake .#default
   ```

2. **Check Internet Connection:**
   ```bash
   ping github.com
   nix-channel --update
   ```

#### Problem: Build failures due to disk space
**Symptoms:** "No space left on device"

**Solutions:**
1. **Clean Nix Store:**
   ```bash
   sudo nix-collect-garbage -d
   sudo nix-store --optimise
   ```

2. **Check Available Space:**
   ```bash
   df -h /nix
   du -sh /nix/store
   ```

3. **Move Nix Store (Advanced):**
   ```bash
   # Only if you have another disk with more space
   # This requires advanced knowledge
   ```

### **Service Start Failures**

#### Problem: Services fail to start after rebuild
**Symptoms:** SystemD services in failed state

**Solutions:**
1. **Check Service Status:**
   ```bash
   systemctl --failed
   systemctl status service-name
   journalctl -u service-name -f
   ```

2. **Common Service Fixes:**
   ```bash
   # Display manager issues
   systemctl restart display-manager
   
   # Network issues
   systemctl restart NetworkManager
   
   # Audio issues
   systemctl --user restart pipewire
   ```

## 📁 Dotfiles Issues

### **Stow Problems**

#### Problem: "No stowable packages found"
**Symptoms:** Dotfiles application fails

**Solutions:**
1. **Check Dotfiles Structure:**
   ```bash
   ls -la ~/.dotfiles/
   tree ~/.dotfiles/  # if available
   ```

2. **Fix Structure for Package Mode:**
   ```bash
   cd ~/.dotfiles
   mkdir config zsh
   mv .config config/
   mv .zshrc zsh/
   stow */
   ```

3. **Fix for Direct Mode:**
   ```bash
   cd ~/.dotfiles
   stow .
   ```

#### Problem: Stow conflicts
**Symptoms:** "WARNING! stowing would cause conflicts"

**Solutions:**
1. **Check Conflicts:**
   ```bash
   cd ~/.dotfiles
   stow --no-folding --verbose .
   ```

2. **Remove Conflicting Files:**
   ```bash
   # Backup existing files
   mv ~/.existing_file ~/.existing_file.backup
   stow .
   ```

3. **Force Overwrite (Careful!):**
   ```bash
   stow --adopt .  # Adopts existing files into stow
   ```

### **GNU Stow Installation Issues**

#### Problem: "GNU Stow not found"
**Solutions:**
```bash
# Install stow system-wide
nix-env -iA nixpkgs.stow

# Or use nix-shell
nix-shell -p stow --run "stow ."
```

## 💾 Disk Configuration Problems

### **UUID Issues**

#### Problem: "UUID not found" after reboot
**Symptoms:** Disk mounting fails at boot

**Solutions:**
1. **Verify UUID:**
   ```bash
   blkid | grep your-disk-name
   ```

2. **Update Configuration:**
   ```bash
   sudo nano /etc/nixos/config/variables.nix
   # Update the UUID in filesystems section
   ```

3. **Regenerate Hardware Config:**
   ```bash
   sudo nixos-generate-config
   sudo nixos-rebuild switch --flake /etc/nixos#default
   ```

### **Filesystem Issues**

#### Problem: "Bad filesystem type" during mount
**Solutions:**
1. **Check Filesystem:**
   ```bash
   file -s /dev/your-disk
   lsblk -f
   ```

2. **Format if Needed:**
   ```bash
   # CAUTION: This will erase data!
   sudo mkfs.ext4 /dev/your-disk
   ```

3. **Update Configuration:**
   ```bash
   # Match fsType in variables.nix with actual filesystem
   fsType = "ext4";  # or "btrfs", "xfs", etc.
   ```

## 🌐 Network and Download Issues

### **Download Failures**

#### Problem: "Failed to download" errors during rebuild
**Solutions:**
1. **Check Internet Connection:**
   ```bash
   ping nixos.org
   ping github.com
   ```

2. **Check DNS:**
   ```bash
   nslookup github.com
   # If fails, try different DNS
   echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
   ```

3. **Use Different Binary Cache:**
   ```bash
   # Add to configuration.nix
   nix.settings.substituters = [ "https://cache.nixos.org/" ];
   ```

### **Proxy Issues**

#### Problem: Behind corporate firewall/proxy
**Solutions:**
```bash
# Set proxy environment variables
export http_proxy=http://proxy.company.com:8080
export https_proxy=http://proxy.company.com:8080
export no_proxy=localhost,127.0.0.1

# Configure Nix
nix-env --option http-proxy http://proxy.company.com:8080
```

## 🔐 Permission and Access Issues

### **Sudo/Root Issues**

#### Problem: "sudo: command not found" or permission denied
**Solutions:**
1. **Check sudo Installation:**
   ```bash
   which sudo
   su -c "nixos-rebuild switch --flake /etc/nixos#default"
   ```

2. **Add User to Wheel Group:**
   ```bash
   sudo usermod -aG wheel username
   # Or manually edit configuration
   ```

### **File Permission Issues**

#### Problem: Can't write to `/etc/nixos`
**Solutions:**
```bash
# Check ownership
ls -la /etc/nixos/

# Fix ownership
sudo chown -R root:root /etc/nixos
sudo chmod 755 /etc/nixos
```

## 🔧 Service Management Issues

### **Fauxmo Service Problems**

#### Problem: Fauxmo won't start automatically
**Symptoms:** Service doesn't start with monitor changes

**Solutions:**
1. **Check Service Status:**
   ```bash
   systemctl status fauxmo
   journalctl -u fauxmo -f
   ```

2. **Verify Sudo Permissions:**
   ```bash
   # Test passwordless sudo for Fauxmo
   sudo systemctl status fauxmo
   # Should not prompt for password
   ```

3. **Manual Service Control:**
   ```bash
   # Start manually
   sudo systemctl start fauxmo
   
   # Check logs for errors
   journalctl -u fauxmo --since="5 minutes ago"
   ```

#### Problem: Monitor detection not triggering Fauxmo
**Solutions:**
1. **Check Monitor Count:**
   ```bash
   hyprctl monitors | grep "Monitor"
   # Should show monitor count changes
   ```

2. **Verify Workspace Manager:**
   ```bash
   # Check if script is running
   ps aux | grep hypr-workspace-manager
   ```

3. **Test Manual Execution:**
   ```bash
   # Simulate docked mode (3 monitors)
   /path/to/hypr-workspace-manager 3
   
   # Simulate laptop mode (1 monitor)
   /path/to/hypr-workspace-manager 1
   ```

### **Polkit Authentication Issues**

#### Problem: No GUI authentication prompts
**Solutions:**
1. **Check Agent Status:**
   ```bash
   systemctl --user status polkit-gnome-authentication-agent-1
   ```

2. **Restart Agent:**
   ```bash
   systemctl --user restart polkit-gnome-authentication-agent-1
   ```

3. **Manual Start:**
   ```bash
   /run/current-system/sw/libexec/polkit-gnome-authentication-agent-1 &
   ```

## 🔄 Rollback and Recovery Procedures

### **System Won't Boot**

#### Emergency Recovery Steps:
1. **Boot from NixOS ISO**
2. **Mount System:**
   ```bash
   sudo mount /dev/nvme0n1p2 /mnt  # Replace with your root partition
   sudo mount /dev/nvme0n1p1 /mnt/boot  # Replace with your boot partition
   ```

3. **Chroot into System:**
   ```bash
   sudo nixos-enter --root /mnt
   ```

4. **Rollback Configuration:**
   ```bash
   # Quick rollback to previous generation
   nixos-rebuild --rollback
   
   # List available generations (limited by rollbackGenerations setting)
   nixos-rebuild list-generations
   
   # Switch to specific generation
   sudo /nix/var/nix/profiles/system-123-link/bin/switch-to-configuration switch
   
   # Check current generation
   nixos-rebuild list-generations | grep current
   ```

### **Generation Management**

#### Problem: Too many old generations consuming disk space
**Solutions:**
1. **Adjust Generation Limit:**
   ```bash
   # Edit variables.nix
   sudo nano /etc/nixos/config/variables.nix
   # Change: rollbackGenerations = 2;  # or desired number
   rebuild
   ```

2. **Manual Cleanup:**
   ```bash
   # Delete old generations (keep last 2)
   sudo nix-collect-garbage --delete-older-than 2d
   
   # Or delete specific generation
   sudo nix-env --delete-generations 123 --profile /nix/var/nix/profiles/system
   ```

### **Restore from Backup**

#### If Installation Created Backup:
```bash
# Backup location (shown during installation)
ls /etc/nixos.backup.*

# Restore backup
sudo rm -rf /etc/nixos/*
sudo cp -r /etc/nixos.backup.*/* /etc/nixos/
sudo nixos-rebuild switch
```

#### Problem: Rollback generations limit reached
**Symptoms:** Can't rollback far enough, important generation was cleaned up

**Solutions:**
1. **Restore from preset:**
   ```bash
   # Use saved preset to recreate configuration
   cd ~/nixos  # or wherever installer is located
   ./install.sh  # Will detect and offer to use preset.conf
   ```

2. **Manual configuration recreation:**
   ```bash
   # Start with minimal config and rebuild
   sudo nixos-generate-config
   # Copy your variables.nix from backup or preset
   sudo cp preset-variables.nix /etc/nixos/config/variables.nix
   ```

### **Complete Reset**

#### Start Over with Clean Installation:
```bash
# Save important data first!
cp -r ~/.config ~/config-backup
cp -r ~/.dotfiles ~/dotfiles-backup

# Remove configuration
sudo rm -rf /etc/nixos/*

# Regenerate basic config
sudo nixos-generate-config

# Run installer again
cd ~/nixos  # or wherever you have the installer
./install.sh
```

## 🔍 Advanced Debugging

### **Enable Verbose Output**

#### Debug Nix Build Issues:
```bash
# Verbose rebuild
sudo nixos-rebuild switch --flake /etc/nixos#default --show-trace --verbose

# Debug specific derivation
nix build --show-trace /etc/nixos#nixosConfigurations.default.config.system.build.toplevel
```

#### Debug Script Issues:
```bash
# Run installer with bash debugging
bash -x ./install.sh

# Or add to script temporarily
set -x  # Enable debugging
set +x  # Disable debugging
```

### **Log Analysis**

#### System Logs:
```bash
# Recent system issues
journalctl --priority=err --since="1 hour ago"

# Specific service logs
journalctl -u display-manager -f
journalctl -u NetworkManager -f

# Boot issues
journalctl -b -1 --priority=err  # Previous boot
```

#### Nix Logs:
```bash
# Nix daemon logs
journalctl -u nix-daemon -f

# Build logs location
ls /nix/var/log/nix/drvs/
```

### **Hardware Debugging**

#### GPU Issues:
```bash
# Check hardware detection
lspci -nn | grep -E "(VGA|3D)"
lshw -c display

# Check loaded drivers
lsmod | grep -E "nvidia|amdgpu|i915"

# Check Xorg logs
journalctl -u display-manager
cat /var/log/X.0.log
```

#### Audio Issues:
```bash
# Check audio hardware
aplay -l
pactl list sinks

# Check PipeWire status
systemctl --user status pipewire
```

## 📞 Getting Help

### **Before Asking for Help**

1. **Gather Information:**
   ```bash
   # System info
   nixos-version
   uname -a
   
   # Hardware info
   lscpu
   lspci
   lsblk -f
   
   # Configuration info
   cat /etc/nixos/config/variables.nix
   ```

2. **Check Logs:**
   ```bash
   # Recent errors
   journalctl --priority=err --since="1 hour ago" --no-pager
   
   # Nix build logs
   journalctl -u nix-daemon --since="1 hour ago" --no-pager
   ```

3. **Create Minimal Reproduction:**
   - Document exact steps that cause the issue
   - Note any error messages verbatim
   - Include system specifications

### **Where to Get Help**

- **GitHub Issues**: Report bugs and feature requests
- **NixOS Discourse**: Community support and discussions
- **NixOS Wiki**: Documentation and guides
- **Matrix/Discord**: Real-time community chat

### **Information to Include**

1. **System Information:**
   - NixOS version
   - Hardware specifications
   - Installation method used

2. **Problem Description:**
   - What you were trying to do
   - What happened instead
   - Complete error messages

3. **Configuration:**
   - Relevant parts of `variables.nix`
   - Any custom modifications
   - Hardware configuration details

---

**Remember**: Most issues have simple solutions. Start with the basic troubleshooting steps before attempting advanced recovery procedures. Always backup important data before making significant changes to your system configuration.