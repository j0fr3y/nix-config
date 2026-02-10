{ config, pkgs, lib, ... }:

{
  imports = [
    ./wayland.nix
  ];

  # Enable display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Enable polkit for privilege elevation
  security.polkit.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable touchpad support
  services.libinput.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
