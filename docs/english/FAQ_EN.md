# Frequently Asked Questions 🤔

Common questions and answers about the NixOS Configuration Installer and setup.

## 📋 Table of Contents

1. [General Questions](#-general-questions)
2. [Installation Questions](#-installation-questions)
3. [Configuration Questions](#-configuration-questions)
4. [Hardware Compatibility](#-hardware-compatibility)
5. [Feature Flags System](#-feature-flags-system)
6. [Dotfiles Integration](#-dotfiles-integration)
7. [Performance and Gaming](#-performance-and-gaming)
8. [Troubleshooting](#-troubleshooting)
9. [Advanced Usage](#-advanced-usage)
10. [Comparison with Other Setups](#-comparison-with-other-setups)

## 🌟 General Questions

### **Q: What is this NixOS configuration?**
**A:** This is a modular, feature-flag-driven NixOS configuration that provides a complete desktop environment with Hyprland. It's designed to be universal - one configuration that adapts to any hardware through centralized variables and boolean flags.

### **Q: Who is this configuration for?**
**A:** Perfect for:
- **Gaming enthusiasts** who want optimized performance
- **Developers** needing a complete development environment
- **Power users** who want a customizable, reproducible system
- **Anyone** wanting a modern NixOS setup without manual configuration

### **Q: What makes this different from other NixOS configurations?**
**A:** Key differences:
- **Universal Design**: One config adapts to any hardware via feature flags
- **Intelligent Installer**: Interactive setup with hardware detection
- **Gaming Focus**: Built-in gaming optimizations and scripts
- **Multilingual**: Full Portuguese and English support
- **Smart Disk Management**: Automatic additional disk detection and mounting

### **Q: Is this beginner-friendly?**
**A:** Yes! The interactive installer guides you through:
- Automatic hardware detection
- Step-by-step configuration
- Clear explanations for each option
- Safe installation with backup options
- Comprehensive documentation

## 🚀 Installation Questions

### **Q: What are the system requirements?**
**A:** Minimum requirements:
- **OS**: NixOS (installer ISO or existing installation)
- **RAM**: 4GB (8GB+ recommended)
- **Storage**: 20GB free space (40GB+ recommended)
- **Architecture**: x86_64
- **Internet**: Required for downloading packages

### **Q: Can I install this on an existing NixOS system?**
**A:** Yes! The installer:
- Offers to backup your existing configuration
- Preserves your `hardware-configuration.nix`
- Allows you to review changes before applying
- Provides rollback options if something goes wrong

### **Q: How long does installation take?**
**A:** Installation time varies:
- **Configuration**: 5-10 minutes (interactive setup)
- **File copying**: 1-2 minutes
- **Rebuild**: 15-45 minutes (depending on enabled features and internet speed)
- **Total**: 20-60 minutes for complete setup

### **Q: Can I run this installer multiple times?**
**A:** Absolutely! The installer:
- Saves your configuration as presets for quick reuse
- Detects existing installations and offers updates
- Allows you to modify features without starting over
- Preserves your customizations between runs

### **Q: What if the installation fails?**
**A:** The installer is designed for safety:
- Creates backups before making changes
- Provides detailed error messages
- Offers rollback options
- Has comprehensive troubleshooting documentation
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for specific solutions

## ⚙️ Configuration Questions

### **Q: Where is the main configuration stored?**
**A:** Key locations:
- **Feature Flags**: `/etc/nixos/config/variables.nix` (central configuration)
- **System Config**: `/etc/nixos/configuration.nix`
- **Home Config**: `/etc/nixos/home.nix`
- **Modules**: `/etc/nixos/modules/` (organized by type)

### **Q: How do I modify the configuration after installation?**
**A:** Several options:
1. **Edit variables.nix**: `sudo nano /etc/nixos/config/variables.nix`
2. **Run installer again**: Re-run `./install.sh` to modify features
3. **Manual editing**: Edit specific module files as needed
4. **Use rebuild command**: `rebuild` after making changes

### **Q: Can I disable features I don't need?**
**A:** Yes! Edit `/etc/nixos/config/variables.nix`:
```nix
features = {
  gaming.enable = false;        # Disable gaming packages
  development.enable = false;   # Disable dev tools
  media.enable = false;         # Disable media applications
  services.virtualbox.enable = false;  # Disable VirtualBox
};
```
Then run: `rebuild`

### **Q: How do I add my own packages?**
**A:** Add packages to the appropriate module:
- **User packages**: `/etc/nixos/modules/packages/home/`
- **System packages**: `/etc/nixos/modules/packages/system/`
- **Custom modules**: Create new files in `/etc/nixos/modules/`

### **Q: Can I use this with different desktop environments?**
**A:** Currently optimized for Hyprland, but you can:
- Keep Hyprland and add other DEs
- Replace Hyprland by editing `/etc/nixos/modules/system/desktop.nix`
- Disable desktop packages and install your preferred DE

## 🔧 Hardware Compatibility

### **Q: Which GPUs are supported?**
**A:** Full support for:
- **AMD**: All modern AMD GPUs with AMDGPU drivers
- **NVIDIA**: GTX 900 series and newer (proprietary drivers)
- **Intel**: All Intel integrated graphics

The installer automatically detects your GPU and configures appropriate drivers.

### **Q: Does this work on laptops?**
**A:** Yes! Laptop-specific features:
- Battery optimization
- Bluetooth support
- WiFi management
- Power management
- Backlight control
- Enable with: `laptop.enable = true;`

### **Q: Can I use this with multiple monitors?**
**A:** Absolutely! Hyprland has excellent multi-monitor support:
- Automatic monitor detection
- Per-monitor workspaces
- Mixed refresh rates and resolutions
- Easy configuration through Hyprland config

### **Q: What about older hardware?**
**A:** The configuration works on most hardware, but:
- **Very old GPUs**: May need manual driver configuration
- **Limited RAM**: Disable heavy features (gaming, development packages)
- **Slow storage**: Installation will take longer but works fine
- **32-bit systems**: Not supported (NixOS requirement)

### **Q: Can I dual boot with Windows?**
**A:** Yes, but requires care:
- Install Windows first, then NixOS
- The installer preserves existing boot entries
- GRUB is configured to detect other operating systems
- Additional disks can be shared between systems

## 🎛️ Feature Flags System

### **Q: What are feature flags?**
**A:** Feature flags are boolean switches that enable/disable parts of the configuration:
```nix
features = {
  gaming.enable = true;      # Enable gaming packages and optimizations
  laptop.enable = false;     # Disable laptop-specific features
  bluetooth.enable = false;  # Disable Bluetooth support
};
```

### **Q: Can I create custom feature flags?**
**A:** Yes! Add to `variables.nix`:
```nix
features = {
  myFeature.enable = true;
};
```
Then reference in your modules:
```nix
{ config, lib, ... }:
let
  vars = import ../config/variables.nix;
in {
  config = lib.mkIf vars.features.myFeature.enable {
    # Your configuration here
  };
}
```

### **Q: How do I see all available feature flags?**
**A:** Check `/etc/nixos/config/variables.nix` for all available options, or see the [Configuration Reference](CONFIGURATION_REFERENCE.md) documentation.

### **Q: Can I have different profiles (work/gaming/etc)?**
**A:** Currently, you can:
- Save different presets with the installer
- Manually switch feature flags as needed
- Future versions will have built-in profile switching

## 📁 Dotfiles Integration

### **Q: How does dotfiles integration work?**
**A:** The installer can:
- Detect existing dotfiles directories
- Apply dotfiles using GNU Stow
- Support both package structure and direct structure
- Handle conflicts gracefully

### **Q: What dotfiles structure is supported?**
**A:** Two structures:
1. **Package Structure** (subdirectories):
   ```
   ~/.dotfiles/
   ├── zsh/
   │   └── .zshrc
   ├── git/
   │   └── .gitconfig
   └── vim/
       └── .vimrc
   ```

2. **Direct Structure** (files directly):
   ```
   ~/.dotfiles/
   ├── .zshrc
   ├── .gitconfig
   └── .vimrc
   ```

### **Q: Can I use my existing dotfiles?**
**A:** Yes! The installer:
- Detects existing dotfiles
- Offers to relocate them if needed
- Applies them automatically after system setup
- Handles conflicts by asking for your preference

### **Q: What if dotfiles conflict with system config?**
**A:** The system handles conflicts by:
- System configuration takes precedence for core functionality
- Dotfiles provide user-specific customizations
- Manual resolution required for major conflicts
- Backup options available for safety

## 🎮 Performance and Gaming

### **Q: How good is gaming performance?**
**A:** Excellent gaming performance with:
- **Native Linux games**: Near-native performance
- **Proton/Wine games**: 90-95% Windows performance typically
- **Optimizations**: CPU governor, I/O schedulers, kernel parameters
- **Tools**: Steam, Lutris, GameMode, MangoHud included

### **Q: How do I enable gaming optimizations?**
**A:** Multiple ways:
1. **During installation**: Enable gaming packages
2. **On-demand scripts**: 
   ```bash
   gaming-mode-on   # Enable optimizations
   gaming-mode-off  # Restore defaults
   ```
3. **Feature flag**: Set `gaming.enable = true;` in `variables.nix`

### **Q: Which games work well?**
**A:** Great compatibility with:
- **Steam games**: Excellent Proton compatibility
- **Native Linux games**: Perfect performance
- **Indie games**: Usually work flawlessly
- **AAA games**: Most work well with Proton
- **Anti-cheat games**: Limited support (improving)

### **Q: Can I use this for streaming/content creation?**
**A:** Yes! Includes:
- **OBS Studio**: For streaming and recording
- **Audio tools**: Professional audio setup with PipeWire
- **Performance**: Optimized for stable frame rates
- **Multi-monitor**: Excellent support for streaming setups

## 🔧 Troubleshooting

### **Q: The installer script won't start**
**A:** Common solutions:
```bash
# Make executable
chmod +x install.sh

# Check you're on NixOS
cat /etc/NIXOS

# Install dependencies
nix-shell -p git curl coreutils
```

### **Q: Rebuild fails with syntax errors**
**A:** Check your configuration:
```bash
# Validate syntax
nix-instantiate --parse /etc/nixos/config/variables.nix

# Common issues: missing semicolons, unmatched braces
sudo nano /etc/nixos/config/variables.nix
```

### **Q: System won't boot after installation**
**A:** Recovery steps:
1. **Boot from NixOS ISO**
2. **Rollback**: `nixos-rebuild --rollback`
3. **Check logs**: `journalctl -xb`
4. **See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed recovery**

### **Q: GPU drivers not working**
**A:** Solutions:
1. **Verify detection**: Check `/etc/nixos/config/variables.nix`
2. **Manual override**: Edit GPU type in variables.nix
3. **Check loading**: `lsmod | grep -E "nvidia|amdgpu"`
4. **Rebuild**: `rebuild` after changes

## 🚀 Advanced Usage

### **Q: Can I use this in a VM?**
**A:** Yes, but with considerations:
- Disable hardware-specific features (GPU acceleration)
- Reduce resource-intensive packages
- Enable virtualization-specific optimizations
- May need manual hardware configuration

### **Q: How do I contribute to this configuration?**
**A:** Contributions welcome:
1. **Fork the repository** on GitHub
2. **Follow coding standards** in [CODING_STANDARDS.md](CODING_STANDARDS.md)
3. **Test thoroughly** on your hardware
4. **Submit pull request** with clear description
5. **Include both Portuguese and English** for user-facing changes

### **Q: Can I use this for servers?**
**A:** Possible but not optimal:
- This config is desktop-focused
- Disable GUI packages: `desktop.enable = false;`
- Create server-specific feature flags
- Consider using minimal NixOS server config instead

### **Q: How do I update to newer versions?**
**A:** Update methods:
1. **Re-run installer**: `./install.sh` with newer version
2. **Manual update**: `cd /etc/nixos && nix flake update`
3. **Monitor releases**: Check GitHub for updates
4. **Backup first**: Always backup before major updates

## 🔄 Comparison with Other Setups

### **Q: How does this compare to other NixOS configs?**
**A:** Advantages:
- **Universal**: Works on any hardware via feature flags
- **Interactive installer**: No manual configuration needed  
- **Gaming-focused**: Built-in optimizations and tools
- **Multilingual**: Portuguese and English support
- **Comprehensive**: Everything included out-of-the-box

### **Q: Should I use this or create my own config?**
**A:** Use this if you want:
- ✅ Quick setup with intelligent defaults
- ✅ Gaming and development focus
- ✅ Regular updates and community support
- ✅ Proven configuration with good hardware support

Create your own if you:
- ❌ Need very specific/minimal setup
- ❌ Want to learn NixOS deeply
- ❌ Have unusual hardware requirements
- ❌ Prefer different desktop environment

### **Q: Can I migrate from other Linux distributions?**
**A:** Yes, but consider:
- **Different package management**: Nix vs traditional packages
- **Configuration approach**: Declarative vs imperative
- **Learning curve**: NixOS concepts take time to master  
- **Benefits**: Reproducibility, rollbacks, atomic updates

### **Q: How does this compare to Arch/Manjaro gaming setups?**
**A:** Comparison:

| Feature | This NixOS Config | Arch/Manjaro |
|---------|------------------|--------------|
| **Setup Time** | 30-60 min automated | Hours of manual work |
| **Gaming Performance** | Excellent, optimized | Excellent with manual tuning |
| **Stability** | Very stable, rollbacks | Good, manual recovery |
| **Customization** | Feature flags, modules | Complete manual control |
| **Updates** | Atomic, safe | Rolling, can break |
| **Reproducibility** | Perfect | Manual documentation needed |

## 📞 Getting More Help

### **Q: Where can I get help if my question isn't here?**
**A:** Several options:
- **Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for technical issues
- **GitHub Issues**: Bug reports and feature requests
- **NixOS Discourse**: Community discussions
- **Matrix/Discord**: Real-time chat support
- **Documentation**: Read the complete guides in `/docs`

### **Q: How do I report bugs or request features?**
**A:** Please:
1. **Check existing issues** on GitHub first
2. **Provide system information**: NixOS version, hardware specs
3. **Include error messages**: Complete logs and error output
4. **Describe expected behavior**: What should happen vs what happens
5. **Include configuration**: Relevant parts of `variables.nix`

### **Q: Can I help improve this documentation?**
**A:** Absolutely! We welcome:
- **Corrections and clarifications**
- **Additional questions and answers**
- **Translation improvements**
- **New sections for common issues**
- **Better examples and explanations**

Submit improvements via GitHub pull requests or issues.

---

**Didn't find your question?** Please [create an issue](https://github.com/JakeMartinezz/hyprland-nix/issues) on GitHub, and we'll add it to this FAQ!