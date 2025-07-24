{ config, pkgs, lib, ... }:

let
  vars = import ../../../config/variables.nix;
  serviceFeatures = vars.features.services;
in

{
  # Essential system packages and configurations
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # System utilities
    wget
    pciutils
    stow
    git
    
    # Basic programming languages
    python3
    
    # System monitoring and hardware
    gnome-system-monitor
    gnome-disk-utility
  ] ++ lib.optionals serviceFeatures.polkit_gnome.enable [
    # Polkit GNOME authentication agent
    polkit_gnome
  ];
}