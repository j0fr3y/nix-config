#!/usr/bin/env bash
set -e

echo "NixOS Installation Script"

# Hostname abfragen
read -p "Hostname für diesen Server: " HOSTNAME

# WICHTIG: Disk anpassen falls nötig
DISK="/dev/sda"

echo "Verwende Disk: $DISK"
read -p "WARNUNG: $DISK wird komplett gelöscht! Fortfahren? (yes/no) " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Abgebrochen."
    exit 1
fi

# Alle Partitionen unmounten falls gemountet
umount ${DISK}* 2>/dev/null || true

# Disk komplett löschen
echo "Lösche alte Partition-Tabelle..."
wipefs -a $DISK

# Partitionierung
echo "Partitioniere $DISK..."
parted $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MB 512MB
parted $DISK -- set 1 esp on
parted $DISK -- mkpart primary 512MB 100%

# Kurz warten damit Kernel die Partitionen sieht
sleep 2

# Formatieren
echo "Formatiere Partitionen..."
mkfs.fat -F 32 -n boot ${DISK}1
mkfs.ext4 -L nixos ${DISK}2 -F

# Kurz warten
sleep 1

# Mounten
echo "Mounte Partitionen..."
mount ${DISK}2 /mnt
mkdir -p /mnt/boot
mount ${DISK}1 /mnt/boot

# Prüfen ob gemountet
if ! mountpoint -q /mnt; then
    echo "ERROR: /mnt ist nicht gemountet!"
    exit 1
fi

echo "Partitionen erfolgreich gemountet:"
lsblk $DISK
df -h /mnt

# Git Repo URL
REPO_URL="https://github.com/j0fr3y/nix-config.git"

# Config-Repo clonen
echo "Clone Config-Repository..."
nix-shell -p git --run "git clone $REPO_URL /mnt/etc/nixos"

# Hardware-Config generieren
echo "Generiere Hardware-Configuration..."
mkdir -p /mnt/etc/nixos/hosts/$HOSTNAME
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/$HOSTNAME/hardware-configuration.nix

# Checken ob Host-Config existiert
if [ ! -f "/mnt/etc/nixos/hosts/$HOSTNAME/configuration.nix" ]; then
    echo "Keine Config für $HOSTNAME gefunden, erstelle Template..."
    cat > /mnt/etc/nixos/hosts/$HOSTNAME/configuration.nix <<EOF
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "$HOSTNAME";
  system.stateVersion = "24.05";
}
EOF
fi

# Installation
echo "Starte NixOS Installation..."
nixos-install --flake /mnt/etc/nixos#$HOSTNAME

echo "Installation abgeschlossen!"
echo "Bitte rebooten: reboot"