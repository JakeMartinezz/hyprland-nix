{ config, pkgs, ... }:

{
  # Desktop environment and compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # File manager and desktop utilities
    nautilus
    
    # Browser
    zen
    
    # Styling and themes
    dart-sass
    brightnessctl
    
    # Note: gtk3 and accountsservice removed - provided by GNOME components and desktop environment
  ];
}