#!/usr/bin/env bash
set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}NixOS Installation Script${NC}"

# Hostname abfragen
read -p "Hostname für diesen Server: " HOSTNAME

# Git Repo URL
REPO_URL="https://github.com/j0fr3y/nix-config.git"  # Anpassen!

# Partitionierung
echo -e "${GREEN}Partitioniere /dev/sda...${NC}"
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MB 100%
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 2 esp on

# Formatieren
echo -e "${GREEN}Formatiere Partitionen...${NC}"
mkfs.ext4 -L nixos /dev/sda1
mkfs.fat -F 32 -n boot /dev/sda2

# Mounten
echo -e "${GREEN}Mounte Partitionen...${NC}"
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# Config-Repo clonen
echo -e "${GREEN}Clone Config-Repository...${NC}"
nix-shell -p git --run "git clone $REPO_URL /mnt/etc/nixos"

# Hardware-Config generieren
echo -e "${GREEN}Generiere Hardware-Configuration...${NC}"
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/$HOSTNAME/hardware-configuration.nix

# Checken ob Host-Config existiert
if [ ! -f "/mnt/etc/nixos/hosts/$HOSTNAME/configuration.nix" ]; then
    echo -e "${RED}Keine Config für $HOSTNAME gefunden!${NC}"
    echo "Erstelle Template..."
    mkdir -p /mnt/etc/nixos/hosts/$HOSTNAME
    cat > /mnt/etc/nixos/hosts/$HOSTNAME/configuration.nix <<EOF
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "$HOSTNAME";
  
  # Weitere Host-spezifische Config hier
}
EOF
fi

# Installation
echo -e "${GREEN}Starte NixOS Installation...${NC}"
nixos-install --flake /mnt/etc/nixos#$HOSTNAME

echo -e "${GREEN}Installation abgeschlossen!${NC}"
echo "Bitte Root-Passwort setzen und rebooten."