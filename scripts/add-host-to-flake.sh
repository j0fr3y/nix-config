#!/usr/bin/env bash
# Automatically add a new host to flake.nix

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <hostname> [desktop|server]"
    exit 1
fi

HOSTNAME=$1
TYPE=${2:-desktop}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_ROOT="$(dirname "$SCRIPT_DIR")"
FLAKE="$CONFIG_ROOT/flake.nix"

echo "Adding $HOSTNAME to flake.nix..."

# This is a simple append - you might want to edit manually for exact placement
cat >> "$FLAKE.new" <<EOF

      # $HOSTNAME configuration
      $HOSTNAME = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/$HOSTNAME/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.user = import ./home/$TYPE.nix;
          }
        ];
      };
EOF

echo "Please manually add the host entry to flake.nix"
echo "Or use: make add-host HOSTNAME=$HOSTNAME TYPE=$TYPE"
