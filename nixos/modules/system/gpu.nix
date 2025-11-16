{ config, pkgs, lib, ... }:

let
  vars = import ../../config/variables.nix;
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
      
      # Shader cache comum para ambas GPUs
      environment.sessionVariables = {
        # Shader cache location (funciona para AMD e NVIDIA)
        __GL_SHADER_DISK_CACHE_PATH = "$HOME/.cache/mesa_shader_cache";
        __GL_SHADER_DISK_CACHE_SIZE = "5G";
        MESA_SHADER_CACHE_DISABLE = "0";
      };
    }
    
    # AMD GPU Configuration
    (lib.mkIf (gpuFeatures.type == "amd" && gpuFeatures.amd.enable) {
      hardware.graphics.extraPackages = with pkgs; [
        libva-utils
        libvdpau-va-gl
        libva-vdpau-driver
      ];
      
      hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        libvdpau-va-gl
        libva-vdpau-driver
      ];
      
      environment.sessionVariables = gpuFeatures.amd.optimizations // {
        # AMD Performance optimizations
        RADV_PERFTEST = "aco,sam,nggc,cas,fma,rtwave";  # Todas features RADV
        AMD_VULKAN_ICD = "RADV";                        # Força RADV
        MESA_GL_VERSION_OVERRIDE = "4.6";                # OpenGL 4.6
        MESA_GLSL_VERSION_OVERRIDE = "460";
        
        # AMD específico para gaming
        RADV_DEBUG = "novrsflatshading";                 # Melhora compatibilidade
        mesa_glthread = "true";                          # Multi-threading OpenGL
        
        # FSR (FidelityFX Super Resolution)
        WINE_FULLSCREEN_FSR = "1";
        WINE_FSR_STRENGTH = "2";                         # 0-5, menor = mais qualidade
        WINE_FSR_OVERRIDE_SHARPNESS = "2";              # Sharpness do FSR
        
        # Disable debugging para performance
        RADV_DEBUG_NO_COMPUTE_QUEUE = "0";
        GALLIUM_HUD_TOGGLE_SIGNAL = "10";                # SIGUSR1 para toggle HUD
      };
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
        libvdpau
        libva-vdpau-driver
        libva-vdpau-driver
        
        # NVIDIA específico
        nvidia-system-monitor-qt # GUI monitor
      ];
      
      hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
        nvidia-vaapi-driver
        libvdpau
        libva-vdpau-driver
        libva-vdpau-driver
      ];
      
      environment.sessionVariables = gpuFeatures.nvidia.optimizations // {
        # NVIDIA Performance optimizations
        __GL_GSYNC_ALLOWED = "1";                        # G-Sync
        __GL_VRR_ALLOWED = "1";                          # Variable Refresh Rate
        __GL_MaxFramesAllowed = "1";                     # Reduz input lag
        __GL_SHADER_DISK_CACHE = "1";                   # Shader cache
        __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";      # Mantém cache
      };
      
      # NVIDIA specific optimizations
      boot.kernelParams = [
        "nvidia-drm.modeset=1"                           # DRM KMS
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Preserva VRAM
        "nvidia.NVreg_TemporaryFilePath=/var/tmp"       # Temp files location
      ];
    })
  ];
}
