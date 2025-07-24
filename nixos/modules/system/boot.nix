{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  # Performance boot optimizations
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "loglevel=0"
    "rd.udev.log_level=0"
    "pcie_aspm=off"
    "nowatchdog"           # Disable hardware watchdog
    "nmi_watchdog=0"       # Disable NMI watchdog  
    "systemd.show_status=0" # Hide systemd boot messages
    "rd.systemd.show_status=0" # Hide initrd messages
  ];
  
  boot.loader.systemd-boot.consoleMode = "max";
  boot.initrd.verbose = false;
  boot.plymouth.enable = false;  # Disable for faster boot
  
  # Use systemd in initrd for faster boot
  boot.initrd.systemd.enable = true;
  
  # Kernel optimizations
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  
  # Faster boot timeout
  boot.loader.timeout = 1;
}
