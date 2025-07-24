{ config, pkgs, lib, ... }:

let
  vars = import ./config/variables.nix;
in

{
  imports = [
    ./modules/home/gtk.nix
    ./modules/home/git.nix
    ./modules/home/zsh.nix
    ./modules/packages/home/core.nix
    ./modules/packages/home/development.nix
    ./modules/packages/home/media.nix
    ./modules/packages/home/gaming.nix
    ./modules/packages/home/desktop.nix
  ];

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";

  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = vars.stateVersion;

xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "zen.desktop";
    "x-scheme-handler/https" = "zen.desktop";
    "x-scheme-handler/about" = "zen.desktop";
    "x-scheme-handler/unknown" = "zen.desktop";
    "inode/directory" = "org.gnome.Nautilus.desktop";
  };
  programs.home-manager.enable = true;
}
