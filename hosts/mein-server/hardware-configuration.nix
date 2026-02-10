# Dies ist nur ein Platzhalter!
#
# Auf dem echten Server wurde beim Installieren eine Datei unter 
# /etc/nixos/hardware-configuration.nix generiert.
#
# Kopiere den Inhalt jener Datei hier hinein oder überschreibe diese Datei.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
