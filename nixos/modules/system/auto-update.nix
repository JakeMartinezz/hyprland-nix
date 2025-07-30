# nixos/modules/system/auto-update.nix
{ config, pkgs, lib, inputs, ... }:

let
  vars = import ../../config/variables.nix;
in
{
  config = lib.mkIf vars.features.services.autoUpdate.enable {
    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
      dates = "weekly";
      allowReboot = false;
    };
    
    # Notificação antes de updates
    systemd.services.nixos-upgrade-notify = {
      description = "Notify before NixOS upgrade";
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.libnotify}/bin/notify-send "NixOS Update" "System update will start in 5 minutes"
      '';
      before = [ "nixos-upgrade.service" ];
    };
  };
}