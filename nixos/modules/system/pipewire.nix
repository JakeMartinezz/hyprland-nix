{ config, pkgs, ... }:

{
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig = {
      pipewire = {
        "context.properties" = {
          # Fix for audio crackling (xrun errors)
          # Higher min-quantum prevents audio dropouts on weak integrated sound chips
          "default.clock.min-quantum" = 1024;
          "default.clock.quantum" = 1024;
          "default.clock.max-quantum" = 8192;
        };
      };
      jack = {
        "context.properties" = {
          "jack.passthrough" = true;
        };
      };
    };
  };
}