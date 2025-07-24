{ config, lib, pkgs, ... }:

let
  vars = import ../../config/variables.nix;
in

{
  # Script to enable gaming optimizations on-demand
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "gaming-mode-on" ''
      echo "🎮 Enabling gaming optimizations..."
      
      # Apply gaming sysctls
      sudo sysctl -w vm.swappiness=10
      sudo sysctl -w vm.vfs_cache_pressure=50
      sudo sysctl -w vm.dirty_background_ratio=5
      sudo sysctl -w vm.dirty_ratio=10
      sudo sysctl -w net.core.rmem_default=262144
      sudo sysctl -w net.core.rmem_max=16777216
      sudo sysctl -w net.core.wmem_default=262144
      sudo sysctl -w net.core.wmem_max=16777216
      sudo sysctl -w net.core.netdev_max_backlog=5000
      sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
      sudo sysctl -w net.core.default_qdisc=fq
      sudo sysctl -w net.ipv4.tcp_fastopen=3
      sudo sysctl -w fs.file-max=2097152
      
      # Set I/O schedulers for gaming
      for disk in /sys/block/nvme*; do
        if [[ -e "$disk/queue/scheduler" ]]; then
          echo "none" | sudo tee "$disk/queue/scheduler" > /dev/null
        fi
      done
      
      for disk in /sys/block/sd*; do
        if [[ -e "$disk/queue/scheduler" && -e "$disk/queue/rotational" ]]; then
          if [[ $(cat "$disk/queue/rotational") == "0" ]]; then
            echo "none" | sudo tee "$disk/queue/scheduler" > /dev/null
          else
            echo "mq-deadline" | sudo tee "$disk/queue/scheduler" > /dev/null
          fi
        fi
      done
      
      # Set CPU governor to performance
      for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        if [[ -e "$cpu/cpufreq/scaling_governor" ]]; then
          echo "performance" | sudo tee "$cpu/cpufreq/scaling_governor" > /dev/null
        fi
      done
      
      echo "✅ Gaming optimizations enabled!"
    '')
    
    (writeShellScriptBin "gaming-mode-off" ''
      echo "🎮 Disabling gaming optimizations..."
      
      # Restore default sysctls
      sudo sysctl -w vm.swappiness=60
      sudo sysctl -w vm.vfs_cache_pressure=100
      sudo sysctl -w vm.dirty_background_ratio=10
      sudo sysctl -w vm.dirty_ratio=20
      sudo sysctl -w net.core.rmem_default=212992
      sudo sysctl -w net.core.rmem_max=212992
      sudo sysctl -w net.core.wmem_default=212992
      sudo sysctl -w net.core.wmem_max=212992
      sudo sysctl -w net.core.netdev_max_backlog=1000
      sudo sysctl -w fs.file-max=1048576
      
      # Restore default I/O schedulers
      for disk in /sys/block/nvme*; do
        if [[ -e "$disk/queue/scheduler" ]]; then
          echo "none" | sudo tee "$disk/queue/scheduler" > /dev/null
        fi
      done
      
      for disk in /sys/block/sd*; do
        if [[ -e "$disk/queue/scheduler" ]]; then
          echo "mq-deadline" | sudo tee "$disk/queue/scheduler" > /dev/null
        fi
      done
      
      # Restore default CPU governor
      for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        if [[ -e "$cpu/cpufreq/scaling_governor" ]]; then
          echo "schedutil" | sudo tee "$cpu/cpufreq/scaling_governor" > /dev/null
        fi
      done
      
      echo "✅ Gaming optimizations disabled!"
    '')
  ];
  
  # Allow sudo for gaming optimization scripts
  security.sudo.extraRules = [
    {
      users = [ vars.username ];
      commands = [
        {
          command = "${pkgs.procps}/bin/sysctl";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.coreutils}/bin/tee";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}