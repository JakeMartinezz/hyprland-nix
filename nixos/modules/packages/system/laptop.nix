{ config, pkgs, lib, ... }:

let
  vars = import ../../../config/variables.nix;
  
  # Use features directly from variables.nix
  laptopFeatures = vars.features.laptop;
  
in

{
  config = lib.mkIf laptopFeatures.enable {
    environment.systemPackages = map (pkg: pkgs.${pkg}) laptopFeatures.packages;
  };
}