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

in
{
  environment.systemPackages = [
    rebuilder
    cleaner
  ];

  environment.shellAliases = {
    rebuild = "${rebuilder}/bin/nixos-rebuilder";
    update = "${rebuilder}/bin/nixos-rebuilder upgrade";
    clean = "${cleaner}/bin/nixos-cleaner";
  };
}
