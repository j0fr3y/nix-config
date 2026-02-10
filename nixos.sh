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
    echo "  bootstrap             Bootstrap a new host (interactive)"
    echo "  update                Update flake inputs"
    echo "  clean                 Clean old generations and garbage collect"
    echo "  list                  List all configured hosts"
    echo "  check                 Check flake configuration"
    echo ""
    echo "Examples:"
    echo "  ./nixos.sh switch laptop1"
    echo "  ./nixos.sh bootstrap"
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
