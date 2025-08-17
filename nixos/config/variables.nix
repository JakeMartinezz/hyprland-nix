{  
  # User configuration
  username = "jake";
  userDescription = "Jake";
  userGroups = [ "networkmanager" "wheel" ];
  
  # System configuration
  hostname = "martinez";
  stateVersion = "25.05";
  
  # Feature flags for hardware and services
  features = {
    # GPU Configuration
    gpu = {
      type = "nvidia"; # "amd", "nvidia", or "intel"
      
      # AMD-specific settings
      amd = {
        enable = false;
        optimizations = {
          RADV_PERFTEST = "aco";
          MESA_GL_THREAD = "true";
        };
      };
      
      # NVIDIA-specific settings
      nvidia = {
        enable = true;
        prime = {
          enable = false;
          sync = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
        optimizations = {
          WLR_NO_HARDWARE_CURSORS = "1";
          NIXOS_OZONE_WL = "1";
          GBM_BACKEND = "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };
      };
    };
    
    # Bluetooth support
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      packages = [ "bluez" "bluez-tools" "blueman" ];
    };
    
    # Laptop-specific features
    laptop = {
      enable = true;
      packages = [ "wpa_supplicant" "hyprlock" ];
    };
    
    # Package categories
    packages = {
      gaming = {
        enable = true;
      };
      development = {
        enable = true;
      };
      media = {
        enable = true;
      };
    };
    
    # GTK Theme configuration
    gtk = {
      theme = "gruvbox";
      icon = "gruvbox-plus-icons";
    };
    
    # Services and integrations
    services = {
      # Fauxmo
      fauxmo = {
        enable = true;
        ports = [ 52002 ]; # TCP ports to open for Fauxmo service
      };
      
      # VirtualBox
      virtualbox = {
        enable = true;
      };
      
      # Polkit GNOME
      polkit_gnome = {
        enable = false;
      };
      
      # Garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      
      # Auto updates
      autoUpdate = {
        enable = true;
      };
      
      # Kanshi display management
      kanshi = {
        enable = true;
      };
    };
    
    # Network features
    network = {
      wakeOnLan = {
        enable = false; 
        interface = "wlp0s20f3";
      };
    };
  };
  
  # Filesystem configuration
  filesystems = {
    drives = {
      disco1 = {
        uuid = "5fc9631f-039b-43ee-b889-15d749130492";
        mountPoint = "/mnt/discos";
        fsType = "ext4";
        options = [ "defaults" "x-gvfs-show" ];
      };
    };
  };
  
  # Paths and directories
  paths = {
    # NixOS configuration path
    configPath = "/etc/nixos";
  };
  
  # Build and performance settings
  build = {
    # Detected automatically but can be overridden
    maxJobs = "auto";
    cores = 0; # Use all cores
    
    # Cache settings
    keepOutputs = true;
    keepDerivations = true;
    autoOptimiseStore = true;
  };
  
}
