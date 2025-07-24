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
      type = "amd"; # "amd", "nvidia", or "intel"
      
      # AMD-specific settings
      amd = {
        enable = true;
        optimizations = {
          RADV_PERFTEST = "aco";
          MESA_GL_THREAD = "true";
        };
      };
      
      # NVIDIA-specific settings
      nvidia = {
        enable = false;
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
      enable = false;
      powerOnBoot = false;
      packages = [ "bluez" "bluez-tools" "blueman" ];
    };
    
    # Laptop-specific features
    laptop = {
      enable = false;
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
    
    # Services and integrations
    services = {
      # Fauxmo
      fauxmo = {
        enable = true;
        ports = [ 52002 3009 ]; # TCP ports to open for Fauxmo service
      };
      
      # VirtualBox
      virtualbox = {
        enable = true;
      };
      
      # Polkit GNOME
      polkit_gnome = {
        enable = false;
      };
    };
    
    # Network features
    network = {
      wakeOnLan = {
        enable = true; 
        interface = "enp6s0";
      };
    };
  };
  
  # Filesystem configuration
  filesystems = {
    drives = {
      disco1 = {
        uuid = "7e119fb3-fb23-48b2-8e71-ee0d53691ecf";
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
  
  # Services and programs
  services = {
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
