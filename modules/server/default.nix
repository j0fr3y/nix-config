{ config, pkgs, lib, ... }:

{
  # Minimal server configuration
  # No GUI, headless operation
  
  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # SSH
  };

  # Basic server utilities
  environment.systemPackages = with pkgs; [
    htop
    tmux
    wget
    curl
    git
  ];
}
