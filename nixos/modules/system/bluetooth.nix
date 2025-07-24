{ config, pkgs, lib, ... }:

let
  vars = import ../../config/variables.nix;
  
  # Use features directly from variables.nix
  bluetoothFeatures = vars.features.bluetooth;
  
in

{
  config = lib.mkIf bluetoothFeatures.enable {
    # Enable bluetooth hardware
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = bluetoothFeatures.powerOnBoot;
    };
    
    # Enable blueman service - delayed start for faster boot
    services.blueman.enable = true;
    
    # Delay bluetooth service startup
    systemd.services.bluetooth = {
      wantedBy = lib.mkForce [ ];
      after = [ "multi-user.target" ];
    };
    
    # Start bluetooth on-demand
    systemd.user.services.bluetooth-on-demand = {
      description = "Start Bluetooth when needed";
      script = ''
        if ${pkgs.bluez}/bin/bluetoothctl show | grep -q "Powered: no"; then
          ${pkgs.systemd}/bin/systemctl start bluetooth
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
    
    # Add bluetooth packages
    environment.systemPackages = map (pkg: pkgs.${pkg}) bluetoothFeatures.packages;
  };
}