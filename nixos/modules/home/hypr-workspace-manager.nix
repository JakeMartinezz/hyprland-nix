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
              
              # Remover keybinds do modo docked primeiro
              hyprctl keyword unbind , Page_Down 2>/dev/null || true
              hyprctl keyword unbind SHIFT, Page_Down 2>/dev/null || true
              
              # Configurar keybind Print para screenshot em modo laptop
              hyprctl keyword bind , Print, exec, "ags -r \"recorder.screenshot(true)\"" 2>/dev/null || true
              hyprctl keyword bind SHIFT, Print, exec, "ags -r \"recorder.screenshot()\"" 2>/dev/null || true
              
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
              
              # Remover keybinds do modo laptop primeiro
              hyprctl keyword unbind , Print 2>/dev/null || true
              hyprctl keyword unbind SHIFT, Print 2>/dev/null || true
              
              # Configurar keybind Page_Down para screenshot em modo docked
              hyprctl keyword bind , Page_Down, exec, "ags -r \"recorder.screenshot(true)\"" 2>/dev/null || true
              hyprctl keyword bind SHIFT, Page_Down, exec, "ags -r \"recorder.screenshot()\"" 2>/dev/null || true
              
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
    
    # Criar link simbólico para configuração editável do kanshi
    xdg.configFile."kanshi/config".source = ../../lib/kanshi.conf;
  };
}
