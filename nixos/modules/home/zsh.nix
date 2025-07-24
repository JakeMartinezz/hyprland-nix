{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lha";
      la = "ls -A";
      grep = "grep --color=auto";
      shutdown = "shutdown -h now";
      "cd.." = "cd ..";
      # Note: rebuild, update, clean are now managed by custom-scripts.nix
    };
    
    initContent = ''

      function random_pokemon() {
        ${pkgs.pokemon-colorscripts}/bin/pokemon-colorscripts -r --no-title
      }
      # chame a função
      random_pokemon

      # --- Prompt e Script de Inicialização ---
      PROMPT="%F{#FFFFFF}╭─%F{#af00d1}%n %{%F{#808080}%}em %F{#008000}%B%~%b%f
      %F{#FFFFFF}╰─%{%F{#FFFFFF}%}o %f"

      # --- Lógica de Compinit e Promptinit ---
      autoload -Uz compinit
      if [[ -n ~/.zcompdump(#qN.m+15) ]]; then
        compinit
      else
        compinit -C
      fi

      autoload -Uz promptinit
      promptinit

      # --- Configuração de Teclas (bindkey) ---
      # CORREÇÃO APLICADA AQUI: Usando "''${...}" para escapar a interpolação para o Nix.
      typeset -g -A key
      key[Home]="''${terminfo[khome]}"
      key[End]="''${terminfo[kend]}"
      key[Left]="''${terminfo[kcub1]}"
      key[Right]="''${terminfo[kcuf1]}"
      key[Control-Left]="''${terminfo[kLFT5]}"
      key[Control-Right]="''${terminfo[kRIT5]}"

      [[ -n "''${key[Home]}"          ]] && bindkey -- "''${key[Home]}"           beginning-of-line
      [[ -n "''${key[End]}"           ]] && bindkey -- "''${key[End]}"            end-of-line
      [[ -n "''${key[Left]}"          ]] && bindkey -- "''${key[Left]}"           backward-char
      [[ -n "''${key[Right]}"         ]] && bindkey -- "''${key[Right]}"          forward-char
      [[ -n "''${key[Control-Left]}"  ]] && bindkey -- "''${key[Control-Left]}"   backward-word
      [[ -n "''${key[Control-Right]}" ]] && bindkey -- "''${key[Control-Right]}"  forward-word

      # --- Hooks do ZLE (Zsh Line Editor) ---
      if (( ''${+terminfo[smkx]} && ''${+terminfo[rmkx]} )); then
        autoload -Uz add-zle-hook-widget
        function zle_application_mode_start { echoti smkx }
        function zle_application_mode_stop { echoti rmkx }
        add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
        add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
      fi
    '';
  };
}
