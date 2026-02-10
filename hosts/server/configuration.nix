{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common
    ../../modules/server
  ];

  # Boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # Update this for your system

  # Networking
  networking.hostName = "nixos-server";

  # User account - extend common config
  users.users.user = {
    description = "Server User";
    # Add your SSH public key here
    # openssh.authorizedKeys.keys = [ "ssh-rsa AAAA..." ];
  };
}
