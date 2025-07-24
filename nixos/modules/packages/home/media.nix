{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Content creation and streaming
    obs-studio
    
    # Audio control
    pavucontrol
    
    # Communication
    vesktop
    anydesk
    
    # Screenshots and screen recording
    slurp
    wayshot
  ];
}