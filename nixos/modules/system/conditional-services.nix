{ config, pkgs, lib, ... }:

let
  vars = import ../../config/variables.nix;
  
  # Use features directly from variables.nix
  serviceFeatures = vars.features.services;
  networkFeatures = vars.features.network;
  
in

{
  config = lib.mkMerge [
    # VirtualBox configuration - lazy loading
    (lib.mkIf serviceFeatures.virtualbox.enable {
      virtualisation.virtualbox.host.enable = true;
      users.extraGroups.vboxusers.members = [ vars.username ];
      
      # Delay VirtualBox kernel modules loading
      systemd.services.virtualbox = {
        wantedBy = lib.mkForce [ ]; # Remove from default.target
        unitConfig.ConditionPathExists = "/dev/vboxdrv";
      };
      
      # Only load when VirtualBox is actually used
      systemd.services.vboxdrv.wantedBy = lib.mkForce [ ];
      systemd.services.vboxnetadp.wantedBy = lib.mkForce [ ];
      systemd.services.vboxnetflt.wantedBy = lib.mkForce [ ];
    })
    
    # Wake-on-LAN configuration
    (lib.mkIf networkFeatures.wakeOnLan.enable {
      networking.interfaces.${networkFeatures.wakeOnLan.interface}.wakeOnLan.enable = true;
    })
    
    # Polkit GNOME authentication agent
    (lib.mkIf serviceFeatures.polkit_gnome.enable {
      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "default.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    })
  ];
}