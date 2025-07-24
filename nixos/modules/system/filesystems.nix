{ config, pkgs, lib, ... }:

let
  vars = import ../../config/variables.nix;
  
  # Create filesystem configurations from drives
  createFileSystems = drives:
    lib.mapAttrs' (name: drive: {
      name = drive.mountPoint;
      value = {
        device = "/dev/disk/by-uuid/${drive.uuid}";
        fsType = drive.fsType;
        options = drive.options or [ "defaults" ];
      };
    }) drives;
  
in

{
  # Configure filesystems from centralized configuration
  fileSystems = lib.mkMerge [
    # Only create filesystems if drives are configured
    (lib.mkIf (vars.filesystems ? drives && vars.filesystems.drives != {}) 
      (createFileSystems vars.filesystems.drives)
    )
  ];
}