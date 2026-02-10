#!/usr/bin/env bash
# Bootstrap script for quick onboarding of new NixOS machines

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== NixOS Quick Onboarding ===${NC}"

# Check if we're on NixOS
if [ ! -f /etc/NIXOS ]; then
    echo -e "${RED}Error: This script must run on NixOS${NC}"
    exit 1
fi

# Get hostname
read -p "Enter hostname for this machine (e.g., laptop1, laptop2, server1): " HOSTNAME
if [ -z "$HOSTNAME" ]; then
    echo -e "${RED}Error: Hostname cannot be empty${NC}"
    exit 1
fi

# Get machine type
echo "Select machine type:"
echo "  1) Desktop/Laptop (with GUI)"
echo "  2) Server (headless)"
read -p "Choice [1/2]: " MACHINE_TYPE

case $MACHINE_TYPE in
    1)
        TYPE="desktop"
        ;;
    2)
        TYPE="server"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Create host directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_ROOT="$(dirname "$SCRIPT_DIR")"
HOST_DIR="$CONFIG_ROOT/hosts/$HOSTNAME"

if [ -d "$HOST_DIR" ]; then
    echo -e "${YELLOW}Warning: Host directory $HOST_DIR already exists${NC}"
    read -p "Overwrite? [y/N]: " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

mkdir -p "$HOST_DIR"

echo -e "${GREEN}Generating hardware configuration...${NC}"
nixos-generate-config --show-hardware-config > "$HOST_DIR/hardware-configuration.nix"

echo -e "${GREEN}Creating configuration.nix...${NC}"
cat > "$HOST_DIR/configuration.nix" <<EOF
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common
    ../../modules/$TYPE
  ];

  # Hostname
  networking.hostName = "$HOSTNAME";

  # Boot configuration - adjust as needed
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Uncomment and configure for GRUB instead:
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";

  # Additional host-specific configuration goes here
}
EOF

echo -e "${GREEN}Host configuration created at: $HOST_DIR${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Edit $HOST_DIR/configuration.nix for host-specific settings"
echo "2. Add this host to flake.nix:"
echo ""
echo "   $HOSTNAME = nixpkgs.lib.nixosSystem {"
echo "     system = \"x86_64-linux\";"
echo "     modules = ["
echo "       ./hosts/$HOSTNAME/configuration.nix"
echo "       home-manager.nixosModules.home-manager"
echo "       {"
echo "         home-manager.useGlobalPkgs = true;"
echo "         home-manager.useUserPackages = true;"
echo "         home-manager.users.user = import ./home/$TYPE.nix;"
echo "       }"
echo "     ];"
echo "   };"
echo ""
echo "3. Run: sudo nixos-rebuild switch --flake .#$HOSTNAME"
echo ""
echo -e "${GREEN}Done!${NC}"
