{ config, lib, pkgs, ... }:

let
  vars = import ../../config/variables.nix;
in

with lib;

{
  config = mkIf vars.features.services.kanshi.enable {
    # Install kanshi package but don't enable systemd service
    home.packages = [ pkgs.kanshi ];

    # Ensure the config directory exists
    home.file.".config/kanshi/.gitkeep".text = "";

    # Add helpful aliases for managing kanshi
    home.shellAliases = {
      kanshi-edit = "editor ~/.config/kanshi/config";
      kanshi-start = "kanshi &";
      kanshi-stop = "pkill kanshi";
      kanshi-status = "ps aux | grep kanshi | grep -v grep";
      kanshi-detect = "wlr-randr";
    };
  };
}