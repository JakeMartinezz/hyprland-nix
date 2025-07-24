{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # File system and archives
    peazip
    
    # Network and communication
    socat
    
    # Terminal utilities
    pokemon-colorscripts
    neofetch
    inxi
    
    # Note: zsh removed - already configured via programs.zsh in system/core.nix and home/zsh.nix
  ];
}