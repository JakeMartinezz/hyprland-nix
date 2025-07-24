{ config, pkgs, ... }:

let
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
      package = pkgs.catppuccin-gtk.override {
        accents = [ "lavender" ];
        variant = "mocha";
      };
      name = "catppuccin-mocha-lavender-standard";
    };
    iconTheme = {
      name = "Tela-dracula";
      package = pkgs.tela-icon-theme;
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