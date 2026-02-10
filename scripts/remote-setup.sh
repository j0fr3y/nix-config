#!/usr/bin/env bash
# One-liner setup for completely automated NixOS onboarding
# Usage: curl -sSL https://your-repo/setup.sh | bash -s -- laptop1 desktop

set -e

HOSTNAME="${1:-$(hostname)}"
TYPE="${2:-desktop}"
REPO="${3:-your-git-repo-url}"

echo "🚀 Automated NixOS Setup"
echo "   Hostname: $HOSTNAME"
echo "   Type: $TYPE"
echo ""

# Clone config if not exists
if [ ! -d "/etc/nixos/.git" ]; then
    echo "📦 Cloning configuration..."
    sudo rm -rf /etc/nixos
    sudo git clone "$REPO" /etc/nixos
    cd /etc/nixos
else
    echo "✓ Configuration already cloned"
    cd /etc/nixos
    sudo git pull
fi

# Make scripts executable
chmod +x nixos.sh scripts/*.sh 2>/dev/null || true

# Run automated setup
echo ""
echo "⚙️  Setting up host..."
./nixos.sh add-host "$HOSTNAME" "$TYPE"

# Switch to configuration
echo ""
echo "🔄 Activating configuration..."
sudo nixos-rebuild switch --flake ".#$HOSTNAME"

echo ""
echo "✅ Setup complete! System is now running with configuration '$HOSTNAME'"
