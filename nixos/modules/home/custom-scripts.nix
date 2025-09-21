{ config, pkgs, lib, ... }:

let
  vars = import ../../config/variables.nix;
  rebuilder = pkgs.writeShellApplication {
    name = "nixos-rebuilder";
    runtimeInputs = with pkgs; [ nixos-rebuild ];
    text = ''
      set -e
      
      if [[ "''${1:-}" == "upgrade" ]]; then
        rebuild_cmd="sudo nixos-rebuild switch --flake ${vars.paths.configPath}#default --upgrade"
        echo "🛡️ Reconstruindo sistema (upgrade)"
      else
        rebuild_cmd="sudo nixos-rebuild switch --flake ${vars.paths.configPath}#default"
        echo "🛡️ Reconstruindo sistema"
      fi
      
      $rebuild_cmd
      
      echo ""
      echo "✅ Reconstrução completa!"
    '';
  };

  # Cleanup script derivation
  cleaner = pkgs.writeShellApplication {
    name = "nixos-cleaner";
    runtimeInputs = with pkgs; [ nixos-rebuild ];
    text = ''
      set -e
      
      sudo -v
      echo "🛡️ Privilégios de root atualizados."
      
      echo ""
      echo "📂 Limpando o lixo do Nix para o usuário atual..."
      nix-collect-garbage
      
      echo ""
      echo "📂 Limpando o lixo do Nix como superusuário e deletando gerações antigas..."
      sudo nix-collect-garbage -d
      
      echo ""
      echo "📂 Otimizando o Nix store..."
      sudo nix-store --optimise
      
      echo ""
      echo "🛠️ Reconstruindo o boot do NixOS..."
      sudo nixos-rebuild boot --flake ${vars.paths.configPath}#default
      
      echo ""
      echo "✅ Limpeza completa!"
    '';
  };

  wallpaper-manager = pkgs.writeShellApplication {
    name = "wallpaper-manager";
    runtimeInputs = with pkgs; [ hyprland swww jq findutils coreutils ];
    text = ''
      set -uo pipefail

      WALLPAPER_DIR="/home/${vars.username}/.wallpapers"

      check_dependencies() {
          local missing_deps=()
          
          if ! command -v hyprctl &> /dev/null; then
              missing_deps+=("hyprctl")
          fi
          
          if ! command -v swww &> /dev/null; then
              missing_deps+=("swww")
          fi
          
          if [ ''${#missing_deps[@]} -ne 0 ]; then
              echo "Erro: Dependências não encontradas: ''${missing_deps[*]}"
              echo "Instale as dependências necessárias e tente novamente."
              exit 1
          fi
      }

      get_monitors() {
          hyprctl monitors -j | jq -r '.[].name' 2>/dev/null || {
              echo "Erro: Não foi possível obter informações dos monitores"
              echo "Certifique-se de que o Hyprland está rodando e jq está instalado"
              exit 1
          }
      }

      get_monitor_info() {
          local monitor_name="$1"
          hyprctl monitors -j | jq -r --arg name "$monitor_name" '.[] | select(.name == $name) | .description' 2>/dev/null || echo "Monitor desconhecido"
      }

      get_wallpapers() {
          if [ ! -e "$WALLPAPER_DIR" ]; then
              echo "Erro: Diretório de wallpapers não encontrado: $WALLPAPER_DIR"
              exit 1
          fi
          
          find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) 2>/dev/null | sort
      }

      select_wallpaper() {
          local monitor="$1"
          shift
          local wallpapers=("$@")
          
          if [ ''${#wallpapers[@]} -eq 0 ]; then
              echo "Nenhum wallpaper encontrado em $WALLPAPER_DIR"
              return 1
          fi
          
          local monitor_info
          monitor_info=$(get_monitor_info "$monitor")
          
          echo
          echo "=== Monitor: $monitor ($monitor_info) ==="
          echo "Wallpapers disponíveis:"
          
          for i in "''${!wallpapers[@]}"; do
              local filename
              filename=$(basename "''${wallpapers[$i]}")
              printf "%2d. %s\n" "$((i + 1))" "$filename"
          done
          
          printf "%2d. Pular este monitor\n" "$((''${#wallpapers[@]} + 1))"
          echo
          
          while true; do
              echo -n "Selecione um wallpaper para $monitor (1-$((''${#wallpapers[@]} + 1))): "
              read -r choice
              
              if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $((''${#wallpapers[@]} + 1)) ]; then
                  if [ "$choice" -eq $((''${#wallpapers[@]} + 1)) ]; then
                      return 1
                  else
                      SELECTED_WALLPAPER="''${wallpapers[$((choice - 1))]}"
                      return 0
                  fi
              else
                  echo "Opção inválida. Digite um número entre 1 e $((''${#wallpapers[@]} + 1))."
              fi
          done
      }

      apply_wallpaper() {
          local monitor="$1"
          local wallpaper="$2"
          
          local monitor_info
          monitor_info=$(get_monitor_info "$monitor")
          echo "Aplicando wallpaper em $monitor ($monitor_info): $(basename "$wallpaper")"
          
          # Execute swww in background and wait for completion
          {
              swww img --outputs "$monitor" --transition-type grow --transition-duration 1.0 "$wallpaper" 2>/dev/null
              echo $? > /tmp/swww_exit_$$
          } &
          
          wait $!
          local exit_code
          exit_code=$(cat /tmp/swww_exit_$$ 2>/dev/null || echo "1")
          rm -f /tmp/swww_exit_$$
          
          if [ "$exit_code" -eq 0 ]; then
              echo "✓ Wallpaper aplicado com sucesso em $monitor"
              return 0
          else
              echo "✗ Erro ao aplicar wallpaper em $monitor"
              return 1
          fi
      }

      main() {
          echo "=== Configurador de Wallpapers para NixOS/Hyprland ==="
          echo
          
          check_dependencies
          
          if ! pgrep -x swww-daemon > /dev/null; then
              echo "Iniciando swww daemon..."
              swww init
              sleep 2
          fi
          
          echo "Detectando monitores..."
          mapfile -t monitors < <(get_monitors)
          
          if [ ''${#monitors[@]} -eq 0 ]; then
              echo "Nenhum monitor detectado"
              exit 1
          fi
          
          echo "Monitores encontrados: ''${monitors[*]}"
          
          echo "Carregando wallpapers de $WALLPAPER_DIR..."
          mapfile -t wallpapers < <(get_wallpapers)
          
          if [ ''${#wallpapers[@]} -eq 0 ]; then
              echo "Nenhum wallpaper encontrado em $WALLPAPER_DIR"
              echo "Formatos suportados: jpg, jpeg, png, webp, bmp"
              exit 1
          fi
          
          echo "Encontrados ''${#wallpapers[@]} wallpapers"
          
          local applied_count=0
          
          for monitor in "''${monitors[@]}"; do
              if select_wallpaper "$monitor" "''${wallpapers[@]}"; then
                  if apply_wallpaper "$monitor" "$SELECTED_WALLPAPER"; then
                      applied_count=$((applied_count + 1))
                  fi
              else
                  echo "Monitor $monitor foi pulado"
              fi
              echo
          done
          
          echo
          echo "=== Resumo ==="
          echo "Wallpapers aplicados em $applied_count de ''${#monitors[@]} monitores"
          
          if [ "$applied_count" -gt 0 ]; then
              echo "✓ Configuração concluída com sucesso!"
          else
              echo "⚠ Nenhum wallpaper foi aplicado"
          fi
      }

      main "$@"
    '';
  };

in
{
  environment.systemPackages = [
    rebuilder
    cleaner
    wallpaper-manager
  ];

  environment.shellAliases = {
    rebuild = "${rebuilder}/bin/nixos-rebuilder";
    update = "${rebuilder}/bin/nixos-rebuilder upgrade";
    clean = "${cleaner}/bin/nixos-cleaner";
    wallpaper-manager = "${wallpaper-manager}/bin/wallpaper-manager";
  };
}
