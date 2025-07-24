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
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 128;
          "default.clock.max-quantum" = 128;
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