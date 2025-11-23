{ config, pkgs, lib, ... }:

let
  vars = import ./config/variables.nix;
in

{
  imports =
    [ 
      ./modules/system/pipewire.nix
      ./modules/system/fonts.nix
      ./modules/system/tz-locale.nix
      ./modules/system/services.nix
      ./modules/system/boot.nix
      ./modules/system/gpu.nix
      ./modules/system/filesystems.nix
      ./modules/packages/system/core.nix
      ./modules/packages/system/desktop.nix
    ] ++ lib.optionals vars.features.bluetooth.enable [
      ./modules/system/bluetooth.nix
    ] ++ lib.optionals vars.features.laptop.enable [
      ./modules/packages/system/laptop.nix
    ] ++ lib.optionals (vars.features.services.virtualbox.enable ||
                        vars.features.services.polkit_gnome.enable ||
                        vars.features.network.wakeOnLan.enable) [
      ./modules/system/conditional-services.nix
    ] ++ lib.optionals vars.features.packages.gaming.enable [
      ./modules/packages/system/gaming.nix
    ] ++ lib.optionals vars.features.packages.media.enable [
      ./modules/packages/system/media.nix
    ] ++ lib.optionals vars.features.services.autoUpdate.enable [
      ./modules/system/auto-update.nix
    ] ++ lib.optionals vars.features.services.docker.enable [
      ./modules/system/docker.nix
    ];


   environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GTK_THEME = let
      themeNames = {
        catppuccin = "catppuccin-mocha-lavender-standard";
        gruvbox = "Gruvbox-Dark";
        gruvbox-material = "Gruvbox-Material-Dark";
      };
    in themeNames.${vars.features.gtk.theme};
  };
 
  nixpkgs.config.allowUnfree = true;

  networking.hostName = vars.hostname;

  networking.networkmanager.enable = true;
  
  networking.firewall.enable = true;

  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.userDescription;
    extraGroups = vars.userGroups;
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  system.stateVersion = vars.stateVersion;

  nix.settings = {
    # Experimental features
    extra-experimental-features = [ "nix-command" "flakes" ];
    
    # Build optimization - utilize all CPU cores
    max-jobs = vars.build.maxJobs;
    cores = vars.build.cores;
    
    # Cache optimization for faster rebuilds
    keep-outputs = vars.build.keepOutputs;
    keep-derivations = vars.build.keepDerivations;
    
    # Build performance improvements
    builders-use-substitutes = true;  # Use substitutes during build
    substitute = true;                # Enable substitutions
    
    # Binary caches
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    
    # System optimizations
    auto-optimise-store = vars.build.autoOptimiseStore;
  };

  nix.gc = {
    automatic = vars.features.services.gc.automatic;
    dates = vars.features.services.gc.dates;
    options = vars.features.services.gc.options;
  };

}

