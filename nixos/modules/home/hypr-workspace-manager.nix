{ config, lib, pkgs, ... }:

let
  vars = import ../../config/variables.nix;
  
  # Script usando comando nativo do AGS para fechar
  kanshi-ags-restart = pkgs.writeShellApplication {
    name = "kanshi-ags-restart";
    runtimeInputs = with pkgs; [ procps hyprland jq networkmanager ];
    text = ''
      #!/usr/bin/env bash
      
      echo "Monitor configuration changed - restarting AGS..."
      
      # Usar comando nativo do AGS para fechar
      if pgrep -f "ags" >/dev/null 2>&1; then
          echo "Stopping AGS..."
          ags -q 2>/dev/null || true
      else
          echo "AGS not running"
      fi
      
      # Detectar número de monitores para ações específicas
      mapfile -t connected_monitors < <(hyprctl monitors -j | jq -r '.[].name' 2>/dev/null | sort)
      monitor_count=''${#connected_monitors[@]}
      
      case "$monitor_count" in
          1)
              # Laptop mode - ativar WiFi, ir para workspace 1, parar serviços dock
              echo "Laptop mode detected - enabling WiFi, switching to workspace 1, stopping dock services..."
              nmcli radio wifi on 2>/dev/null || true
              hyprctl dispatch workspace 1 2>/dev/null || true
              
              # Parar EasyEffects
              if pgrep -f "easyeffects" >/dev/null 2>&1; then
                  echo "Stopping EasyEffects..."
                  pkill -f "easyeffects" 2>/dev/null || true
              fi
              
              # Parar ArchiSteamFarm
              if pgrep -f "ArchiSteamFarm" >/dev/null 2>&1; then
                  echo "Stopping ArchiSteamFarm..."
                  pkill -f "ArchiSteamFarm" 2>/dev/null || true
              fi
              ;;
          3)
              # Docked mode - desativar WiFi, iniciar serviços dock
              echo "Docked mode detected - disabling WiFi, starting dock services..."
              nmcli radio wifi off 2>/dev/null || true
              
              # Iniciar EasyEffects se não estiver rodando
              if ! pgrep -f "easyeffects" >/dev/null 2>&1; then
                  echo "Starting EasyEffects..."
                  easyeffects --gapplication-service >/dev/null 2>&1 &
              fi
              
              # Iniciar ArchiSteamFarm se não estiver rodando
              if ! pgrep -f "ArchiSteamFarm" >/dev/null 2>&1; then
                  echo "Starting ArchiSteamFarm..."
                  ArchiSteamFarm >/dev/null 2>&1 &
              fi
              ;;
          *)
              echo "Unknown monitor configuration: $monitor_count monitors"
              ;;
      esac
      
      # Iniciar AGS
      echo "Starting AGS..."
      ags >/dev/null 2>&1 &
      
      echo "AGS restart completed"
    '';
  };

in

with lib;

{
  config = mkIf vars.features.services.kanshi.enable {
    # Instalar script
    home.packages = [ 
      kanshi-ags-restart
    ];
    
    # Configurar kanshi para apenas reiniciar AGS
    xdg.configFile."kanshi/config".text = lib.mkAfter ''
# Configuração Kanshi para gerenciamento de monitores
# Apenas reinicia AGS quando configuração de monitores muda

# Perfil apenas notebook (configuração atual)
profile laptop_only {
    output "eDP-1" mode 1920x1080@165.00Hz position 0,0 scale 1.0
    exec ${kanshi-ags-restart}/bin/kanshi-ags-restart
}

# Perfil dock - Cenário 1: DP-3=AOC, DP-4=Synaptics
profile docked_dp3_aoc {
    output "DP-3" mode 1920x1080@74.97Hz position 0,0 scale 1.0
    output "DP-4" mode 1920x1080@60.0Hz position 1920,-585 scale 1.0 transform 270
    output "eDP-1" mode 1920x1080@60.01Hz position 3000,115 scale 1.0
    exec ${kanshi-ags-restart}/bin/kanshi-ags-restart
}

# Perfil dock - Cenário 2: DP-4=AOC, DP-3=Synaptics (se trocar)
profile docked_dp4_aoc {
    output "DP-4" mode 1920x1080@74.97Hz position 0,0 scale 1.0
    output "DP-3" mode 1920x1080@60.0Hz position 1920,-585 scale 1.0 transform 270
    output "eDP-1" mode 1920x1080@60.01Hz position 3000,115 scale 1.0
    exec ${kanshi-ags-restart}/bin/kanshi-ags-restart
}
    '';
  };
}
