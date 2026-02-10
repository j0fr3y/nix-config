#!/usr/bin/env bash
set -e

# =========================
# BASIC CONFIG (Defaults)
# =========================
DEFAULT_HOSTNAME="nixos"
USERNAME="user"
TIMEZONE="Europe/Berlin"

# =========================
# Hostname abfragen
# =========================
echo
read -rp "Hostname [${DEFAULT_HOSTNAME}]: " HOSTNAME
HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME}

echo ">>> Hostname gesetzt auf: $HOSTNAME"

# =========================
# Disk-Auswahl
# =========================
echo
echo "=== Verfügbare Festplatten ==="
echo

lsblk -d -o NAME,SIZE,MODEL | nl -w2 -s'. '

echo
read -rp "Welche Platte installieren? (Nummer): " DISK_NUM

DISK_NAME=$(lsblk -d -o NAME | sed -n "${DISK_NUM}p")

if [ -z "$DISK_NAME" ]; then
  echo "Ungültige Auswahl. Abbruch."
  exit 1
fi

DISK="/dev/$DISK_NAME"

echo
echo ">>> GEWÄHLT: $DISK"
read -rp ">>> ALLES auf $DISK wird GELÖSCHT. WEITER? (yes): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Abgebrochen."
  exit 1
fi

# =========================
# Partitionieren (UEFI)
# =========================
parted -s "$DISK" mklabel gpt

# EFI
parted -s "$DISK" mkpart ESP fat32 1MiB 512MiB
parted -s "$DISK" set 1 esp on

# Root: von 512MiB bis "2GiB vor Ende"
parted -s "$DISK" mkpart primary ext4 512MiB 100%-2GiB

# Swap: letzte 2GiB
parted -s "$DISK" mkpart primary linux-swap 100%-2GiB 100%

# =========================
# Formatieren
# =========================
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 "${DISK}2"
mkswap "${DISK}3"

# =========================
# Mounten
# =========================
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot
swapon "${DISK}3"

# =========================
# Config generieren
# =========================
nixos-generate-config --root /mnt

# =========================
# configuration.nix ergänzen
# =========================
cat >> /mnt/etc/nixos/configuration.nix <<EOF

networking.hostName = "$HOSTNAME";
time.timeZone = "$TIMEZONE";

users.users.$USERNAME = {
  isNormalUser = true;
  extraGroups = [ "wheel" ];
};

services.openssh.enable = true;
services.xserver.enable = false;

environment.systemPackages = with pkgs; [
  vim
  git
  curl
];

security.sudo.wheelNeedsPassword = false;
EOF

# =========================
# Installieren
# =========================
nixos-install --no-root-passwd

echo
echo ">>> Setze Passwort für $USERNAME"
nixos-enter --root /mnt -c "passwd $USERNAME"

echo
echo ">>> Installation abgeschlossen 🎉"
echo ">>> reboot, USB raus"