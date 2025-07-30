{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Gaming platforms and launchers
    lutris
    umu-launcher
    
    # Gaming utilities
    mangohud
    gamescope
  ];

}