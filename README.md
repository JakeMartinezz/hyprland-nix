# NixOS Configuration

![NixOS Badge](https://img.shields.io/badge/NixOS-0d1117?style=for-the-badge&logo=nixos&logoColor=white)
![Hyprland Badge](https://img.shields.io/badge/Hyprland-0d1117?style=for-the-badge&logo=wayland&logoColor=white)
![Shell Script](https://img.shields.io/badge/Shell_Script-0d1117?style=for-the-badge&logo=gnu-bash&logoColor=white)

![Demo](docs/demo.png)

> Jake's Modular NixOS Configuration with Hyprland

## 🏗️ Architecture & Design

This NixOS configuration follows principles of **modularization**, **separation of concerns**, and **centralized variables**. The structure is built upon functional layers that complement each other.

### Design Philosophy

- **📦 Responsibility-Based Modularization**: Each module has a specific function
- **🎯 System vs Home Separation**: Clear distinction between system and user configurations  
- **🔄 Configuration Centralization**: Hardcoded values eliminated through centralized variables
- **⚡ Performance Optimization**: Optimized builds and intelligent caching
- **🔧 Multi-Host Scalability**: Ready for multiple machines

## 📁 Detailed Project Structure

```
nixos/
├── 🔧 config/                     # CONFIGURATION LAYER
│   └── variables.nix              # Single source of truth - centralized feature flags
│
├── 📚 lib/                        # REUSABLE LIBRARIES & COMPONENTS
│   └── fauxmo.nix                 # Alexa integration (IoT)
│
├── 🧩 modules/                    # MAIN MODULAR LAYER
│   ├── 🏠 home/                   # Home Manager modules (user)
│   │   ├── custom-scripts.nix     # Custom scripts (rebuild/clean/update)
│   │   ├── gaming-on-demand.nix   # On-demand gaming optimizations
│   │   ├── git.nix                # Git configuration
│   │   ├── gtk.nix                # GTK themes
│   │   └── zsh.nix                # Zsh shell with custom prompt
│   │
│   ├── 📦 packages/               # PACKAGE MANAGEMENT LAYER
│   │   ├── home/                  # User packages (home.packages)
│   │   │   ├── core.nix           # Essential user tools
│   │   │   ├── development.nix    # Development environment
│   │   │   ├── gaming.nix         # Gaming applications
│   │   │   ├── media.nix          # Media and communication
│   │   │   └── desktop.nix        # Desktop/GUI applications
│   │   └── system/                # System packages (environment.systemPackages)
│   │       ├── core.nix           # Fundamental system tools
│   │       ├── desktop.nix        # Desktop environment (Hyprland, Nautilus)
│   │       ├── gaming.nix         # System gaming components
│   │       └── media.nix          # System media components
│   │
│   └── ⚙️ system/                 # System configuration modules
│       ├── boot.nix               # Boot configuration (XanMod, Plymouth)
│       ├── conditional-services.nix # Conditional services (VirtualBox, Fauxmo, WoL)
│       ├── filesystems.nix        # Centralized filesystem configuration
│       ├── fonts.nix              # System fonts
│       ├── gpu.nix                # GPU configuration (AMD/NVIDIA) with feature flags
│       ├── pipewire.nix           # PipeWire audio system
│       ├── services.nix           # System services (GDM, power management)
│       └── tz-locale.nix          # Timezone and localization
│
├── 🌟 flake.nix                   # ENTRY POINT - universal single configuration
├── ⚙️ configuration.nix           # Main system configuration
├── 🏠 home.nix                    # Main Home Manager configuration
├── 🚀 install.sh                  # Intelligent interactive installer
├── ⚙️ variables.sh                # Customizable installer configurations
└── 📋 preset.conf                 # Saved configuration preset (auto-generated)
```

## 🎯 How Layers Interact

### 1. **Configuration Layer (`config/`)**
- **Purpose**: Single source of truth for all variables
- **Design**: Hierarchical structure that separates configurations by scope
- **Benefit**: Centralized changes, elimination of hardcoded values

```nix
# Example of variables.nix structure
{
  username = "jake";          # Used in configuration.nix and home.nix
  hostname = "martinez";      # Used in configuration.nix
  filesystems.diskUUID = "...";  # Used in modules/system/filesystems.nix
  paths.backupPath = "...";   # Used in custom-scripts.nix
}
```

### 2. **Feature Flag System (`variables.nix`)**
- **Purpose**: Universal configuration adaptable via boolean flags
- **Design**: Features conditionally enabled/disabled
- **Scalability**: Infinite combinations of features via flags

```nix
# config/variables.nix - Centralized feature flags
{
  features = {
    gpu = {
      type = "amd"; # "amd" | "nvidia" | "intel"
      amd.enable = true;
    };
    laptop.enable = false; # Desktop mode
    
    # Theme Configuration
    gtk = {
      theme = "gruvbox";              # "catppuccin" | "gruvbox" | "gruvbox-material"
      icon = "gruvbox-plus-icons";    # "tela-dracula" | "gruvbox-plus-icons"
    };
    
    services = {
      fauxmo = {
        enable = true;
        ports = [ 52002 ]; # Firewall configuration
      };
      polkit_gnome = {
        enable = true; # GNOME authentication agent
      };
      autoUpdate = {
        enable = false; # Weekly automatic updates (disabled by default)
      };
    };
  };
}
```

### 3. **Main Modular Layer (`modules/`)**

#### **3.1 Home Manager (`modules/home/`)**
- **Responsibility**: User-specific configurations
- **Scope**: Dotfiles, aliases, custom scripts
- **Isolation**: Separated from system configurations

#### **3.2 Package Management (`modules/packages/`)**
- **Innovative Design**: Separation between `system/` and `home/`
- **Advantage**: Avoids conflicts between system and user packages
- **Thematic Organization**: Packages grouped by function (core, development, gaming, media)

```nix
# System vs User - Practical example
system/core.nix:     git, python3, wget           # Fundamental tools
home/development.nix: vscode, claude-code, yarn   # Dev-specific tools
```

#### **3.3 System (`modules/system/`)**
- **Responsibility**: Low-level system configurations
- **Modularization**: Each system aspect in separate file
- **Maintainability**: Easy debugging and modification

## 🔄 Boot Flow

```
1. flake.nix
   ├── Loads variables.nix (centralized feature flags)
   ├── Defines consolidated overlays (zen, pokemon-colorscripts, ags)
   └── Builds universal "default" configuration
       │
2. configuration.nix
   ├── Imports conditional modules (gpu.nix, conditional-services.nix)
   ├── Applies feature flags from variables.nix
   └── Configures Nix settings (optimized builds)
       │
3. home.nix
   ├── Imports home modules (zsh, git, packages/home/*)
   ├── Configures Home Manager with feature flags
   └── Applies conditional user configurations
       │
4. modules/system/*.nix
   ├── gpu.nix: Conditional AMD/NVIDIA configuration
   ├── conditional-services.nix: VirtualBox, Fauxmo, WoL, Polkit GNOME
   ├── filesystems.nix: Centralized disk and mounting
   └── Other system modules
```

## ⚡ Architectural Optimizations

### **Build Performance**
- **Parallel Builds**: Utilizes all 12 available cores
- **Cached Derivations**: `keep-outputs` and `keep-derivations` enabled
- **Overlay Consolidation**: All overlays centralized in flake.nix

### **Intelligent Modularization**
- **Lazy Loading**: Modules loaded only when necessary
- **Separation of Concerns**: Each module has a single responsibility
- **Dependency Management**: Clearly defined dependencies

### **Scalability**
- **Multi-Systems Ready**: Easy addition of new features
- **Variable-Driven**: Adaptable configurations via variables.nix
- **Profile System**: Foundation for different profiles (gaming, work, etc.)

## 🧠 Design Decisions

### **Why use Feature Flags instead of Hosts?**
- **Universal Configuration**: Single configuration adapts to any hardware
- **Scalability**: New features enabled/disabled via variables.nix
- **Maintainability**: Elimination of code duplication between hosts
- **Flexibility**: Custom feature combinations per machine

### **Why centralize overlays in flake.nix?**
- **Single Source of Truth**: Avoids overlay duplication
- **Consistency**: Same overlays applied in system and home
- **Maintainability**: Modifications in one place only

### **Why use variables.nix?**
- **DRY Principle**: Don't Repeat Yourself
- **Type Safety**: Nix automatically checks types
- **Refactoring**: Simplified mass changes

## 🎮 Specific Features

### **Gaming on Demand**
```nix
# gaming-on-demand.nix - Intelligent optimization system
gaming-mode-on  → Applies performance sysctls + CPU governor
gaming-mode-off → Restores default settings
```

### **Advanced Gaming Configuration**
```nix
# Enhanced gamemode settings with system-level configuration
programs.gamemode = {
  enable = true;
  settings = {
    general = {
      renice = 10;              # Higher priority for games
      inhibit_screensaver = 1;  # Prevent screensaver during gaming
    };
  };
};
# Steam with Proton-GE compatibility layers
# Vulkan tools and performance utilities included
```

### **Dynamic Theme System**
```nix
# GTK Theme Selection - Dynamic switching without rebuilds
gtk = {
  theme = "gruvbox";              # "catppuccin" | "gruvbox" | "gruvbox-material"
  icon = "gruvbox-plus-icons";    # "tela-dracula" | "gruvbox-plus-icons"
};
# Icon colors automatically applied (gruvbox icons → grey folders)
# Themes conditionally installed (only selected themes downloaded)
```

### **Automatic System Updates**
```nix
# Optional weekly auto-updates with notifications
system.autoUpgrade = {
  enable = true;                  # Controlled via features.services.autoUpdate.enable
  flake = inputs.self.outPath;
  flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
  dates = "weekly";
  allowReboot = false;            # Safe: no automatic reboots
};
# 5-minute notification before updates via libnotify
```

### **Custom Scripts**
```bash
rebuild → nixos-rebuild switch --flake ${configPath}#default
update  → nixos-rebuild switch --flake ${configPath}#default --upgrade  
clean   → GC + optimization + backup to ${backupPath}
```

### **Polkit Authentication**
```nix
# Polkit GNOME Authentication Agent
# Enabled via features.services.polkit_gnome.enable = true
# Systemd user service configured automatically
# Allows graphical authentication for privileged operations
```

### **IoT Integration**
```nix
# lib/fauxmo.nix - Alexa-NixOS Bridge
# Enabled via features.services.fauxmo.enable = true
# Firewall configured automatically via features.services.fauxmo.ports
# IP detected automatically at service startup
```

## 📚 Documentation

### **📖 Complete Guides**
- **[Configuration Guide](docs/english/GUIDE_EN.md)**: Detailed guide with examples and customization instructions
- **[Guia de Configuração](docs/portuguese/GUIDE_PT.md)**: Guia detalhado com exemplos e instruções de customização
- **[Portuguese README](docs/portuguese/README.md)**: Documentação completa em português

### **🔧 Technical Documentation**
- **[Coding Standards](docs/english/CODING_STANDARDS.md)**: Development guidelines and best practices
- **[Commit Standards](docs/english/COMMIT_STANDARDS.md)**: Conventional commits guide and patterns

### **❓ Help & Support**
- **[FAQ](docs/english/FAQ_EN.md)**: Frequently asked questions and answers
- **[Troubleshooting](docs/english/TROUBLESHOOTING_EN.md)**: Common issues and solutions
- **[FAQ Português](docs/portuguese/FAQ_PT.md)**: Perguntas frequentes e respostas
- **[Solução de Problemas](docs/portuguese/TROUBLESHOOTING_PT.md)**: Problemas comuns e soluções

## ⚙️ Customizable Configuration System (variables.sh)

This configuration includes an innovative customization system through the `variables.sh` file, allowing you to customize the installer behavior without modifying the main code.

### **🔧 Available Configurations**

The `variables.sh` file allows you to customize:

```bash
# Repositories and URLs
DOTFILES_REPO_URL="https://github.com/YourUsername/your-repo"
DOTFILES_BRANCH="main"

# System paths
NIXOS_CONFIG_PATH="/etc/nixos"              # Configuration directory
MOUNT_POINT_PREFIX="/mnt"                   # Mount point prefix
BACKUP_DIR_PREFIX="/etc/nixos.backup"       # Backup directory

# Default configurations
DEFAULT_USERNAME="${USER:-jake}"            # Default username
DEFAULT_HOSTNAME="${HOSTNAME:-nixos}"       # Default hostname

# Technical configurations
DEFAULT_MOUNT_OPTIONS="defaults,x-gvfs-show"  # Mount options
MIN_FREE_SPACE_MB=2048                         # Minimum required space
NETWORK_TIMEOUT=30                             # Network operations timeout
```

### **✨ System Benefits**

- **🎯 Easy Customization**: Edit only one file to customize the installer
- **🔄 Backward Compatibility**: Works with or without `variables.sh`
- **🛡️ Safety**: Default values ensure functionality even without customization
- **📦 Portability**: Configurations separated from main code
- **🚀 Maintainability**: Installer updates don't affect your customizations

### **📝 How to Use**

1. **Customize (Optional)**: Edit the `variables.sh` file with your preferences
2. **Run Installer**: The script automatically detects your configurations
3. **Automatic Backup**: Your customizations are preserved during updates

```bash
# Usage example
cp variables.sh variables.sh.backup  # Backup your configurations
# Edit variables.sh as needed
./install.sh  # The installer automatically uses your configurations
```

## 🚀 Quick Start

### **Using the Intelligent Installer**

```bash
# Clone the repository
git clone https://github.com/JakeMartinezz/hyprland-nix.git ~/nixos
cd ~/nixos

# Make the installer executable and run it
chmod +x install.sh
./install.sh
```

The installer provides a comprehensive interactive setup experience:

#### **🎯 Installation Script Features**

- **🔧 Hardware Detection**: Automatic GPU detection (AMD/NVIDIA/Intel) with proper driver configuration
- **💾 Smart Disk Management**: Automatically detects additional disks and configures mount points
- **📋 Configuration Presets**: Save and reuse complete configurations for quick reinstalls
- **🌐 Multilingual Interface**: Full English/Portuguese support with smart defaults
- **🔒 Safe Installation**: Preview configuration before applying, optional backup of existing setup
- **⚙️ Mount Options**: Customizable mount options with intelligent defaults (`defaults,x-gvfs-show`)

#### **💡 Installation Process**

1. **System Detection**: Automatically detects your hardware configuration
2. **Interactive Setup**: Choose GPU type, enable/disable features, configure services
3. **Disk Configuration**: Detect and configure additional storage devices
4. **Configuration Preview**: Review complete setup before installation
5. **Safe Deployment**: Backup existing config (optional) and deploy new configuration

#### **📁 Preset System Example**

```bash
📁 Saved configuration found!

Configuration Details:
  Username: jake
  Hostname: martinez
  GPU Type: amd
  Laptop: false
  Bluetooth: false
  Gaming: true
  Development: true
  Media: true
  VirtualBox: true
  Fauxmo/Alexa: true
  Additional Disks: 1 configured
    • External Disk: /mnt/external (ext4, 931.5G)
  Created: Wed Jul 23 14:32:45 -03 2025

Use this configuration? (Y/n):
```

### **Manual Configuration**

```bash
# Customize features in config/variables.nix
features = {
  gpu.type = "amd";        # or "nvidia"/"intel"
  laptop.enable = false;   # true for laptop
  services.fauxmo.enable = true; # Alexa integration
};

# Apply configuration
rebuild
```

## 🎛️ Intelligent Installer Features

The configuration includes a sophisticated installer script (`install.sh`) with advanced features:

### **🔧 Interactive Configuration**
- **GPU Detection**: Automatic selection between AMD, NVIDIA, and Intel
- **Hardware Features**: Laptop-specific settings, Bluetooth support
- **Service Selection**: VirtualBox, Alexa integration, gaming packages
- **Disk Management**: Automatic detection and configuration of additional disks

### **💾 Smart Disk Detection**
```bash
Additional disks/partitions detected:

  [1] /dev/sdb1
      Size: 931.5G
      Filesystem: ext4
      UUID: 12345678-abcd-4def-9012-3456789abcde
      Label: External

# Automatically suggests mount point based on label: /mnt/external
```

### **⚙️ Mount Options Customization**
- **Recommended defaults**: `defaults,x-gvfs-show` (shows in file manager)
- **Custom options**: Performance tweaks, compression, user mounting
- **Intelligent parsing**: Converts user input to proper Nix array format

### **📁 Configuration Presets**
The installer includes a powerful preset system:

```bash
📁 Saved configuration found!

Saved configuration found:
  Username: jake
  Hostname: martinez
  GPU Type: amd
  Laptop: false
  Bluetooth: false
  Gaming: true
  Development: true
  Media: true
  VirtualBox: true
  Fauxmo/Alexa: true
  Additional Disks: 1 configured
    Disk details:
      • disco1:
        UUID: 12345678-abcd-4def-9012-3456789abcde
        Mount: /mnt/external
        Filesystem: ext4
        Options: "defaults" "x-gvfs-show"
  Configuration created on: Wed Jul 23 14:32:45 -03 2025

Do you want to use this saved configuration? (Y/n):
```

### **🌐 Multilingual Support**
- **English/Portuguese**: Automatically adapts interface language
- **Consistent UX**: All messages and prompts respect language choice
- **Smart defaults**: Culturally appropriate defaults per language

### **🔒 Safe Installation Process**
1. **Configuration Collection**: Gathers all user preferences first
2. **Preview & Confirmation**: Shows complete configuration before proceeding
3. **Selective Backup**: Optional backup of existing NixOS configuration
4. **Clean Installation**: Copies only essential files, excludes documentation
5. **Hardware Preservation**: Keeps existing `hardware-configuration.nix`

### **📋 Preset Management**
- **Automatic Saving**: Offers to save configuration for future reuse
- **Instant Reuse**: Skip entire configuration process with saved presets
- **Portable Presets**: Saved in script directory (`preset.conf`)
- **Detailed Display**: Shows creation date and complete disk configurations

This architecture was designed to be **maintainable**, **scalable**, and **performant**, following NixOS community best practices while adding specific innovations for an optimized desktop setup.
