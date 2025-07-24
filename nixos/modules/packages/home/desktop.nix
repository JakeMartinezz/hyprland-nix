{ config, pkgs, ... }:

{
  # Note: Overlays moved to flake.nix for centralized management
  
  home.packages = with pkgs; [
    # Desktop widgets and utilities
    ags_1
    
    # Terminal
    kitty
    
    # Wallpaper
    swww
    
    # Text editor
    gnome-text-editor
    
    # Icons
    tela-icon-theme
  ];
}