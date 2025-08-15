{ config, pkgs, ... }:

{
  # Gaming programs and services
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

 programs.gamescope = {
  enable = true;
  capSysNice = true;
};    

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        inhibit_screensaver = 1;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    gamemode
    vulkan-tools
  ];
}
