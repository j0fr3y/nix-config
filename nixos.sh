#!/usr/bin/env bash
# NixOS Configuration Helper Script
# Works without make being installed

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${GREEN}NixOS Configuration Helper${NC}"
    echo ""
    echo "Usage: ./nixos.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  switch [hostname]     Switch to configuration (uses current hostname if not specified)"
    echo "  test [hostname]       Test configuration without switching"
    echo "  build [hostname]      Build configuration without activating"
    echo "  bootstrap             Bootstrap a new host (fully automated)"
    echo "  add-host <name> <type> Add new host non-interactively (type: desktop|server)"
    echo "  update                Update flake inputs"
    echo "  clean                 Clean old generations and garbage collect"
    echo "  list                  List all configured hosts"
    echo "  check                 Check flake configuration"
    echo ""
    echo "Examples:"
    echo "  ./nixos.sh switch laptop1"
    echo "  ./nixos.sh bootstrap"
    echo "  ./nixos.sh add-host laptop2 desktop"
    echo "  ./nixos.sh update"
    echo ""
}

get_hostname() {
    if [ -n "$1" ]; then
        echo "$1"
    else
        hostname
    fi
}

list_hosts() {
    echo -e "${BLUE}Configured hosts:${NC}"
    ls -1 hosts/ | grep -v common | grep -v hardware-configuration.nix.example | grep -v ".md"
}

cmd_switch() {
    local host=$(get_hostname "$1")
    echo -e "${GREEN}Switching to configuration: $host${NC}"
    sudo nixos-rebuild switch --flake ".#$host"
}

cmd_test() {
    local host=$(get_hostname "$1")
    echo -e "${YELLOW}Testing configuration: $host${NC}"
    sudo nixos-rebuild test --flake ".#$host"
}

cmd_build() {
    local host=$(get_hostname "$1")
    echo -e "${BLUE}Building configuration: $host${NC}"
    sudo nixos-rebuild build --flake ".#$host"
}

cmd_update() {
    echo -e "${BLUE}Updating flake inputs...${NC}"
    nix flake update
}

cmd_clean() {
    echo -e "${YELLOW}Cleaning old generations...${NC}"
    sudo nix-collect-garbage -d
    if command -v home-manager &> /dev/null; then
        home-manager expire-generations "-7 days"
    fi
}

cmd_check() {
    echo -e "${BLUE}Checking flake configuration...${NC}"
    nix flake check
}

cmd_bootstrap() {
    if [ -f "scripts/bootstrap.sh" ]; then
        bash scripts/bootstrap.sh
    else
        echo -e "${RED}Error: bootstrap.sh not found${NC}"
        exit 1
    fi
}

cmd_add_host() {
    local hostname="$1"
    local type="${2:-desktop}"
    
    if [ -z "$hostname" ]; then
        echo -e "${RED}Error: hostname required${NC}"
        echo "Usage: ./nixos.sh add-host <hostname> [desktop|server]"
        exit 1
    fi
    
    if [[ ! "$type" =~ ^(desktop|server)$ ]]; then
        echo -e "${RED}Error: type must be 'desktop' or 'server'${NC}"
        exit 1
    fi
    add-host)
        cmd_add_host "$2" "$3"
        ;;
    
    local host_dir="hosts/$hostname"
    
    if [ -d "$host_dir" ]; then
        echo -e "${YELLOW}Warning: Host directory $host_dir already exists${NC}"
        read -p "Continue anyway? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    echo -e "${GREEN}Creating host: $hostname (type: $type)${NC}"
    
    # Create directory
    mkdir -p "$host_dir"
    
    # Generate hardware config if on NixOS
    if [ -f /etc/NIXOS ]; then
        echo -e "${BLUE}Generating hardware configuration...${NC}"
        nixos-generate-config --show-hardware-config > "$host_dir/hardware-configuration.nix"
        echo -e "${GREEN}✓ Hardware configuration generated${NC}"
    else
        echo -e "${YELLOW}! Not on NixOS - you'll need to generate hardware-configuration.nix manually${NC}"
        touch "$host_dir/hardware-configuration.nix"
    fi
    
    # Create configuration.nix
    cat > "$host_dir/configuration.nix" <<EOF
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common
    ../../modules/$type
  ];

  # Hostname
  networking.hostName = "$hostname";

  # Boot configuration - adjust as needed
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Uncomment and configure for GRUB instead:
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";

  # Additional host-specific configuration goes here
}
EOF
    
    echo -e "${GREEN}✓ Configuration created${NC}"
    
    # Add to flake.nix
    if [ -f "flake.nix" ]; then
        cp flake.nix flake.nix.backup
        
        if grep -q "^      $hostname = mkSystem" flake.nix; then
            echo -e "${YELLOW}! Host already exists in flake.nix${NC}"
        else
            if grep -q "# Add your laptops and servers here:" flake.nix; then
                sed -i.tmp "/# Add your laptops and servers here:/a\\
      $hostname = mkSystem \"$hostname\" \"$type\";
" flake.nix
                rm -f flake.nix.tmp
                echo -e "${GREEN}✓ Added to flake.nix${NC}"
            fi
        fi
    fi
    
    echo ""
    echo -e "${GREEN}=== Host '$hostname' created successfully! ===${NC}"
    echo ""
    echo -e "Activate with: ${BLUE}./nixos.sh switch $hostname${NC}"
}

# Main
case "${1:-help}" in
    switch)
        cmd_switch "$2"
        ;;
    test)
        cmd_test "$2"
        ;;
    build)
        cmd_build "$2"
        ;;
    bootstrap)
        cmd_bootstrap
        ;;
    update)
        cmd_update
        ;;
    clean)
        cmd_clean
        ;;
    list)
        list_hosts
        ;;
    check)
        cmd_check
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
