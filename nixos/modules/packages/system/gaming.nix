{ config, pkgs, ... }:

{
  # Gaming programs and services
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    gamemode
    vulkan-tools
  ];
}