# Modular NixOS Configuration

A fully modular NixOS configuration supporting both desktop (with Wayland) and server setups. This configuration can be used with both NixOS and standalone Home Manager on any Linux system.

## Features

### Desktop Configuration
- **Wayland Support**: Uses Hyprland compositor for a modern, tiling window manager experience
- **Beautiful Desktop**: Includes Waybar status bar, Wofi launcher, Mako notifications
- **Applications**: Pre-configured Neovim, VSCode, and Firefox
- **Audio**: PipeWire for low-latency audio
- **Fonts**: Nerd Fonts (FiraCode, JetBrains Mono) for a great terminal experience

### Server Configuration
- **Minimal**: Headless configuration for servers
- **Secure**: SSH hardened, firewall enabled
- **Essential Tools**: Git, Neovim, and system utilities

### Modularity
- Easily switch between desktop and server profiles
- Reusable application modules
- Standalone Home Manager support for non-NixOS systems

## Repository Structure

```
.
├── flake.nix                    # Main flake configuration
├── hosts/                       # Host-specific configurations
│   ├── desktop/
│   │   └── configuration.nix    # Desktop NixOS config
│   └── server/
│       └── configuration.nix    # Server NixOS config
├── modules/                     # Reusable NixOS modules
│   ├── desktop/
│   │   ├── default.nix          # Desktop module entry point
│   │   └── wayland.nix          # Wayland/Hyprland setup
│   ├── server/
│   │   └── default.nix          # Server module
│   └── applications/
│       ├── neovim.nix           # Neovim configuration
│       ├── vscode.nix           # VSCode configuration
│       └── firefox.nix          # Firefox configuration
└── home/                        # Home Manager configurations
    ├── desktop.nix              # Desktop user environment
    ├── server.nix               # Server user environment
    └── config/
        └── hypr/
            └── hyprland.conf    # Hyprland window manager config
```

## Usage

### For NixOS (Full System Configuration)

1. **Clone this repository**:
   ```bash
   git clone https://github.com/j0fr3y/nix-config.git
   cd nix-config
   ```

2. **Customize for your system**:
   - Edit `hosts/desktop/configuration.nix` or `hosts/server/configuration.nix`
   - Update timezone, hostname, and user settings
   - For desktop: Verify boot loader settings match your system
   - For server: Update boot loader device and add SSH keys

3. **Build and switch** (for desktop):
   ```bash
   sudo nixos-rebuild switch --flake .#desktop
   ```

   Or for server:
   ```bash
   sudo nixos-rebuild switch --flake .#server
   ```

### For Standalone Home Manager (Non-NixOS)

If you're using another Linux distribution but want to use Nix for user environment management:

1. **Install Nix with flakes** (if not already installed):
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

2. **Clone this repository**:
   ```bash
   git clone https://github.com/j0fr3y/nix-config.git
   cd nix-config
   ```

3. **Install Home Manager** (first time only):
   ```bash
   nix run home-manager/master -- init --switch
   ```

4. **Apply configuration**:
   ```bash
   home-manager switch --flake .#user@desktop
   ```

   Or for minimal server setup:
   ```bash
   home-manager switch --flake .#user@server
   ```

## Customization

### Adding New Applications

1. Create a new module in `modules/applications/`:
   ```nix
   # modules/applications/myapp.nix
   { config, pkgs, lib, ... }:
   {
     programs.myapp = {
       enable = true;
       # configuration here
     };
   }
   ```

2. Import it in `home/desktop.nix` or `home/server.nix`:
   ```nix
   imports = [
     ../modules/applications/myapp.nix
   ];
   ```

### Creating a New Host

1. Create a new directory under `hosts/`:
   ```bash
   mkdir -p hosts/myhost
   ```

2. Create `hosts/myhost/configuration.nix`:
   ```nix
   { config, pkgs, lib, ... }:
   {
     imports = [
       ../../modules/desktop  # or ../../modules/server
     ];
     # Your host-specific configuration
   }
   ```

3. Add it to `flake.nix`:
   ```nix
   nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     modules = [ ./hosts/myhost/configuration.nix ];
   };
   ```

### Modifying Desktop Environment

The desktop uses Hyprland as the Wayland compositor. Configuration is in:
- `modules/desktop/wayland.nix` - System-level Wayland setup
- `home/config/hypr/hyprland.conf` - Hyprland keybindings and appearance

### Key Bindings (Hyprland)

- `SUPER + Return` - Open terminal (Kitty)
- `SUPER + D` - Application launcher (Wofi)
- `SUPER + Q` - Close window
- `SUPER + F` - Fullscreen
- `SUPER + E` - File manager
- `SUPER + 1-9` - Switch workspace
- `SUPER + SHIFT + 1-9` - Move window to workspace
- `Print` - Screenshot area
- `SHIFT + Print` - Screenshot full screen

## Updating

To update all inputs (nixpkgs, home-manager):

```bash
nix flake update
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#desktop
# or
home-manager switch --flake .#user@desktop
```

## Tips

### Garbage Collection

Clean up old generations to free disk space:
```bash
sudo nix-collect-garbage -d
# For home-manager
home-manager expire-generations "-7 days"
```

### Testing Changes

Test configuration without switching:
```bash
sudo nixos-rebuild test --flake .#desktop
```

Build without activating:
```bash
sudo nixos-rebuild build --flake .#desktop
```

### Rollback

If something breaks, you can rollback at boot or manually:
```bash
sudo nixos-rebuild switch --rollback
```

## Troubleshooting

### Hyprland won't start
- Ensure your GPU drivers are properly configured
- Check if Wayland is supported by your hardware
- Review logs: `journalctl -xe`

### Applications not appearing in launcher
- Rebuild home-manager configuration
- Clear cache: `rm -rf ~/.cache/wofi`

## Contributing

Feel free to fork and customize this configuration for your needs!

## License

This configuration is provided as-is for educational and personal use.