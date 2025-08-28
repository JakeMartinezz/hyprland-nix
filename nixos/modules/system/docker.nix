{ config, pkgs, lib, ... }:

let
  vars = import ../../config/variables.nix;
  dockerFeatures = vars.features.services.docker;
in

{
  config = lib.mkIf dockerFeatures.enable {
    # Enable Docker service
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      
      # Enable rootless mode for better security
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      
      # Auto-prune to save disk space
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    # Add user to docker group
    users.users.${vars.username}.extraGroups = [ "docker" ];

    # Docker packages
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
      docker-buildx
    ] ++ lib.optionals dockerFeatures.portainer.enable [
      # Portainer will be managed as a container, not a system package
    ];

    # Portainer container service
    systemd.services.portainer = lib.mkIf dockerFeatures.portainer.enable {
      description = "Portainer Docker Management UI";
      after = [ "docker.service" ];
      wants = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "start-portainer" ''
          ${pkgs.docker}/bin/docker run -d \
            --name portainer \
            --restart=always \
            -p 9000:9000 \
            -p 9443:9443 \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v portainer_data:/data \
            portainer/portainer-ce:latest || true
        '';
        
        ExecStop = pkgs.writeShellScript "stop-portainer" ''
          ${pkgs.docker}/bin/docker stop portainer || true
          ${pkgs.docker}/bin/docker rm portainer || true
        '';
      };
    };

    # Open firewall ports for Portainer
    networking.firewall.allowedTCPPorts = lib.mkIf dockerFeatures.portainer.enable [ 9000 9443 ];

    # Environment variables
    environment.sessionVariables = lib.mkIf dockerFeatures.enable {
      DOCKER_BUILDKIT = "1";
    };
  };
}