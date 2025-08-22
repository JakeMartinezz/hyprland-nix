{ config, pkgs, lib, ... }:

let
  vars = import ../config/variables.nix;
  serviceFeatures = vars.features.services;
  
  # Script to get local IP address
  getLocalIpScript = pkgs.writeShellScript "get-local-ip" ''
    ${pkgs.iproute2}/bin/ip route get 1 | ${pkgs.gawk}/bin/awk '{print $7; exit}'
  '';

  myFauxmo = pkgs.python3Packages.buildPythonApplication {
    pname = "fauxmo";
    version = "0.5.2";
    src = pkgs.fetchFromGitHub {
      owner = "n8henrie";
      repo = "fauxmo";
      rev = "v0.5.2";
      hash = "sha256-79yk35rk0IpthX6iP7RC9/9WTT2vL11GFtw9CCYOC/E=";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [ requests xmltodict zeroconf ];
    pyproject = true;
    build-system = with pkgs.python3Packages; [ setuptools ];
    doCheck = false;
  };

  # Fauxmo configuration as Nix expression
  fauxmoConfig = {
    FAUXMO = {
      ip_address = "0.0.0.0"; # Will be dynamically set by the service
    };
    PLUGINS = {
      CommandLinePlugin = {
        DEVICES = [
          {
            name = "computador";
            port = lib.elemAt serviceFeatures.fauxmo.ports 0;
            on_cmd = "echo 'Comando Ligar para o PC nao faz nada.'";
            off_cmd = "/run/current-system/sw/bin/shutdown -h now";
            state_cmd = "echo ''";
          }
        ];
      };
    };
  };

  # Convert Nix expression to JSON
  fauxmoConfigFile = pkgs.writeText "fauxmo.json" (builtins.toJSON fauxmoConfig);

  # Service script that dynamically sets IP and starts fauxmo
  fauxmoStartScript = pkgs.writeShellScript "start-fauxmo" ''
    LOCAL_IP=$(${getLocalIpScript})
    echo "Detected local IP: $LOCAL_IP"
    
    # Create config with dynamic IP
    ${pkgs.jq}/bin/jq --arg ip "$LOCAL_IP" '.FAUXMO.ip_address = $ip' ${fauxmoConfigFile} > /tmp/fauxmo-runtime.json
    
    # Start fauxmo with dynamic config
    exec ${myFauxmo}/bin/fauxmo -c /tmp/fauxmo-runtime.json
  '';

in
{
  # Fauxmo service - controlled manually by hypr-workspace-manager
  systemd.services.fauxmo = {
    description = "Fauxmo Alexa Bridge (Monitor controlled)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    # Note: No wantedBy - service is controlled by monitor configuration changes

    serviceConfig = {
      User = "root";
      Group = "root";
      ExecStart = fauxmoStartScript;
      Restart = "no"; # Manual control only
      RuntimeDirectory = "fauxmo";
    };
  };
}