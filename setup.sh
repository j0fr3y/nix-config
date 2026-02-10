#!/usr/bin/env bash
set -euo pipefail

# NixOS Minimal Installation Script
# WARNUNG: Dieses Script löscht ALLE Daten auf der Ziel-Festplatte!

# Konfiguration
DISK="/dev/sda"  # Ändere dies zu deiner Festplatte (z.B. /dev/nvme0n1)
HOSTNAME="nixos-minimal"

echo "======================================"
echo "NixOS Minimal Installation"
echo "======================================"
echo "Ziel-Festplatte: $DISK"
echo "Hostname: $HOSTNAME"
echo ""
echo "WARNUNG: Alle Daten auf $DISK werden gelöscht!"
read -p "Fortfahren? (yes/no): " -r
if [[ ! $REPLY =~ ^yes$ ]]; then
    echo "Installation abgebrochen."
    exit 1
fi

# Partitionierung
echo ""
echo "==> Partitioniere Festplatte..."
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary 512MiB 100%

# Partition-Namen setzen (unterschiedlich für SATA/NVMe)
if [[ $DISK == *"nvme"* ]]; then
    BOOT="${DISK}p1"
    ROOT="${DISK}p2"
else
    BOOT="${DISK}1"
    ROOT="${DISK}2"
fi

# Formatierung
echo ""
echo "==> Formatiere Partitionen..."
mkfs.fat -F 32 -n BOOT "$BOOT"
mkfs.ext4 -L nixos "$ROOT"

# Mount
echo ""
echo "==> Mounte Partitionen..."
mount "$ROOT" /mnt
mkdir -p /mnt/boot
mount "$BOOT" /mnt/boot

# Generiere Basis-Konfiguration
echo ""
echo "==> Generiere NixOS-Konfiguration..."
nixos-generate-config --root /mnt

# Erstelle minimale configuration.nix
cat > /mnt/etc/nixos/configuration.nix << 'EOF'
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Netzwerk
  networking.hostName = "HOSTNAME_PLACEHOLDER";
  networking.networkmanager.enable = true;

  # Zeitzone
  time.timeZone = "Europe/Berlin";

  # Locale
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # User
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
  };

  # Minimale System-Pakete
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
  ];

  # SSH (optional)
  services.openssh.enable = true;

  # Automatische Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Flakes aktivieren (optional, aber empfohlen)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
EOF

# Hostname einsetzen
sed -i "s/HOSTNAME_PLACEHOLDER/$HOSTNAME/g" /mnt/etc/nixos/configuration.nix

# Installation
echo ""
echo "==> Installiere NixOS..."
nixos-install --no-root-passwd

echo ""
echo "======================================"
echo "Installation abgeschlossen!"
echo "======================================"
echo ""
echo "Nächste Schritte:"
echo "1. Reboote das System: reboot"
echo "2. Login mit User 'user' und Passwort 'changeme'"
echo "3. Ändere das Passwort: passwd"
echo "4. Root-Passwort setzen: sudo passwd root"
echo ""
echo "Konfiguration bearbeiten:"
echo "  sudo vim /etc/nixos/configuration.nix"
echo "  sudo nixos-rebuild switch"