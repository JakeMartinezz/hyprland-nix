{ config, pkgs, ... }:

let
  vars = import ../../config/variables.nix;
  currentTheme = vars.features.gtk.theme;
  currentIcon = vars.features.gtk.icon;
  
  # Theme configurations
  themeConfigs = {
    catppuccin = {
      package = pkgs.catppuccin-gtk.override {
        accents = [ "lavender" ];
        variant = "mocha";
      };
      name = "catppuccin-mocha-lavender-standard";
    };
    gruvbox = {
      package = pkgs.gruvbox-gtk-theme;
      name = "Gruvbox-Dark";
    };
    gruvbox-material = {
      package = pkgs.gruvbox-material-gtk-theme;
      name = "Gruvbox-Material-Dark";
    };
  };
  
  # Icon theme configurations
  iconConfigs = {
    tela-dracula = {
      package = pkgs.tela-icon-theme;
      name = "Tela-dracula";
    };
    gruvbox-plus-icons = {
      package = pkgs.gruvbox-plus-icons.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          # Aplicar cor grey aos ícones de pasta
          cd "$out/share/icons/Gruvbox-Plus-Dark/places/scalable"
          
          # Recriar links para cor grey
          ln -sfn folder-grey.svg folder.svg
          ln -sfn bookmarks-grey.svg folder-bookmark.svg
          
          # Aplicar grey a outros ícones de pasta
          for file in *-grey*.svg; do
            if [[ -f "$file" && "$file" != "folder-grey.svg" && "$file" != "bookmarks-grey.svg" ]]; then
              target_name="''${file/-grey/}"
              if [[ -f "$target_name" || -L "$target_name" ]]; then
                ln -sfn "$file" "$target_name"
              fi
            fi
          done
          
          echo "Applied grey color to Gruvbox Plus Dark folder icons"
        '';
      });
      name = "Gruvbox-Plus-Dark";
    };
  };
  
  selectedTheme = themeConfigs.${currentTheme};
  selectedIcon = iconConfigs.${currentIcon};
  
  windowsCursorsGithub = pkgs.stdenv.mkDerivation {
    pname = "windows-cursors-github";
    version = "1.0";

    src = pkgs.fetchurl {
      url = "https://github.com/birbkeks/windows-cursors/releases/download/1.0/windows-cursors.tar.gz";
      sha256 = "0pw0p2dm57aiyz1vg3nklq6gi8l416fq8nnzqs51g85aj38brxi3";
    };

    installPhase = ''
      mkdir -p "$out/share/icons/Windows Cursors"
      cp -r ./* "$out/share/icons/Windows Cursors/"
    '';
  };
in
{
  gtk = {
    enable = true;
    theme = {
      package = selectedTheme.package;
      name = selectedTheme.name;
    };
    iconTheme = {
      name = selectedIcon.name;
      package = selectedIcon.package;
    };
  };

   home.pointerCursor = {
    name = "Windows Cursors"; 
    package = windowsCursorsGithub; 
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = [ windowsCursorsGithub ];
}
