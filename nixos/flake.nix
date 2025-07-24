{
  description = "Jake's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    
   home-manager = {
     url = "github:nix-community/home-manager";
     inputs.nixpkgs.follows = "nixpkgs";
   };
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, ... }@inputs:
    let
      system = "x86_64-linux";
      vars = import ./config/variables.nix;

      # Consolidated overlays
      allOverlays = [
        # Pokemon colorscripts overlay
        (final: prev: {
          pokemon-colorscripts = prev.stdenv.mkDerivation {
            pname = "pokemon-colorscripts";
            version = "main";

            src = prev.fetchFromGitLab {
              owner = "phoneybadger";
              repo = "pokemon-colorscripts";
              rev = "0483c85b93362637bdd0632056ff986c07f30868";
              sha256 = "sha256-rj0qKYHCu9SyNsj1PZn1g7arjcHuIDGHwubZg/yJt7A=";
            };

            buildInputs = with prev; [
              bash
              python3
            ];

            installPhase = ''
              mkdir -p $out/opt/pokemon-colorscripts
              mkdir -p $out/bin

              cp -r colorscripts $out/opt/pokemon-colorscripts
              cp pokemon-colorscripts.py $out/opt/pokemon-colorscripts
              cp pokemon.json $out/opt/pokemon-colorscripts

              ln -s $out/opt/pokemon-colorscripts/pokemon-colorscripts.py $out/bin/pokemon-colorscripts
              chmod +x $out/bin/pokemon-colorscripts
            '';

            meta = with final.lib; {
              description = "Utilitário de linha de comando para imprimir imagens de pokemon no terminal";
              homepage = "https://gitlab.com/phoneybadger/pokemon-colorscripts";
              license = licenses.mit;
              platforms = platforms.all;
              mainProgram = "pokemon-colorscripts";
            };
          };
        })
        
        # Zen browser overlay
        (final: prev: {
          zen = zen-browser.packages.${prev.system}.default;
        })
        
        # AGS overlay for desktop
        (final: prev: {
          ags_1 = prev.ags_1.overrideAttrs (old: {
            buildInputs = old.buildInputs ++ [ prev.libdbusmenu-gtk3 ];
          });
        })
      ];

      mkNixosSystem = { hostname, system, specialArgs, modules }:
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ({ pkgs, ... }: {
              nixpkgs.overlays = allOverlays;
            })

             ./configuration.nix
      	     ./hardware-configuration.nix
             ./modules/home/custom-scripts.nix
             ./modules/home/gaming-on-demand.nix

              home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${vars.username} = { pkgs, ... }:
              {
                imports = [./home.nix];
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = allOverlays;
              };
            }
            
          ] ++ modules;
        };

    in
    {
      nixosConfigurations = {
        default = mkNixosSystem {
          hostname = "default";
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            # All configuration is now centralized in variables.nix and modules/
            # No host-specific files needed
          ];
        };
      };
    };
}
