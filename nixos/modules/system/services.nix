{ config, pkgs, lib, ... }:

{
  services.power-profiles-daemon.enable = true;
  services.fstrim.enable = true;
  services.thermald.enable = true;
  services.upower.enable = true;
  services.gvfs.enable = true;

  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

  services.tlp.enable = lib.mkDefault (
    (lib.versionOlder (lib.versions.majorMinor lib.version) "21.05")
    || !config.services.power-profiles-daemon.enable
  );
}