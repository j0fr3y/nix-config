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

# Automatically add host to flake.nix
echo ""
echo -e "${GREEN}Adding host to flake.nix...${NC}"

FLAKE_FILE="$CONFIG_ROOT/flake.nix"
if [ ! -f "$FLAKE_FILE" ]; then
    echo -e "${RED}Error: flake.nix not found${NC}"
    exit 1
fi

# Backup flake.nix
cp "$FLAKE_FILE" "$FLAKE_FILE.backup"
echo -e "${YELLOW}Backup created: flake.nix.backup${NC}"

# Check if host already exists in flake.nix
if grep -q "^      $HOSTNAME = mkSystem" "$FLAKE_FILE"; then
    echo -e "${YELLOW}Host '$HOSTNAME' already exists in flake.nix${NC}"
else
    # Find the line with "# Add your laptops and servers here:" and insert after it
    if grep -q "# Add your laptops and servers here:" "$FLAKE_FILE"; then
        # Insert new host after the comment line
        sed -i.tmp "/# Add your laptops and servers here:/a\\
      $HOSTNAME = mkSystem \"$HOSTNAME\" \"$TYPE\";
" "$FLAKE_FILE"
        rm -f "$FLAKE_FILE.tmp"
        echo -e "${GREEN}✓ Added $HOSTNAME to flake.nix${NC}"
    else
        # Fallback: try to insert before the closing brace of nixosConfigurations
        sed -i.tmp "/^    };$/i\\
      $HOSTNAME = mkSystem \"$HOSTNAME\" \"$TYPE\";
" "$FLAKE_FILE"
        rm -f "$FLAKE_FILE.tmp"
        echo -e "${GREEN}✓ Added $HOSTNAME to flake.nix${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the generated configuration in: $HOST_DIR"
echo "2. Activate the configuration:"
echo ""
echo -e "   ${GREEN}./nixos.sh switch $HOSTNAME${NC}"
echo ""
echo "   or directly:"
echo -e "   ${GREEN}sudo nixos-rebuild switch --flake .#$HOSTNAME${NC}"
echo ""
echo -e "${GREEN}Done!${NC}"
