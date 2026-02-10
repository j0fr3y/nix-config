{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common
    ../../modules/desktop
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-desktop";

  # User account - extend common config
  users.users.user = {
    description = "Desktop User";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
  };

  # Allow unfree packages (for vscode, etc.)
  nixpkgs.config.allowUnfree = true;
}
