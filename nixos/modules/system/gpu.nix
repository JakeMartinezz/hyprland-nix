{ config, pkgs, lib, ... }:

let
  vars = import ../../config/variables.nix;
  
  # Use features directly from variables.nix
  gpuFeatures = vars.features.gpu;
  
in

{
  config = lib.mkMerge [
    # Common graphics settings
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    }
    (lib.mkIf (gpuFeatures.type == "amd" && gpuFeatures.amd.enable) {
      hardware.graphics.extraPackages = with pkgs; [
        libva-utils
        libvdpau-va-gl
        vaapiVdpau
      ];
      
      environment.sessionVariables = gpuFeatures.amd.optimizations;
    })
    
    # NVIDIA GPU Configuration
    (lib.mkIf (gpuFeatures.type == "nvidia" && gpuFeatures.nvidia.enable) {
      services.xserver.videoDrivers = ["nvidia"];
      
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        
        prime = lib.mkIf gpuFeatures.nvidia.prime.enable {
          sync.enable = gpuFeatures.nvidia.prime.sync;
          intelBusId = gpuFeatures.nvidia.prime.intelBusId;
          nvidiaBusId = gpuFeatures.nvidia.prime.nvidiaBusId;
        };
      };
      
      hardware.graphics.extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libvdpau-va-gl
      ];
      
      environment.sessionVariables = gpuFeatures.nvidia.optimizations;
    })
  ];
}