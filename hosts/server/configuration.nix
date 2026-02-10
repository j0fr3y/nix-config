{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/server
  ];

  # Boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # Update this for your system

  # Networking
  networking.hostName = "nixos-server";

  # Time zone
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.user = {
    isNormalUser = true;
    description = "Server User";
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
    # Add your SSH public key here
    # openssh.authorizedKeys.keys = [ "ssh-rsa AAAA..." ];
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  system.stateVersion = "24.05";
}
