{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Media players
    vlc
    
    # Audio processing
    easyeffects
  ];
}