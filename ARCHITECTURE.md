# Architecture Overview

This document explains the architecture and design decisions of this NixOS configuration.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        flake.nix                            │
│              (Entry Point & Orchestration)                  │
└───────────────────┬─────────────────┬───────────────────────┘
                    │                 │
        ┌───────────▼──────────┐     │
        │  nixosConfigurations │     │
        │   - desktop          │     │
        │   - server           │     │
        └───────────┬──────────┘     │
                    │                │
        ┌───────────▼──────────┐     └──────────┬──────────────┐
        │    hosts/            │                 │              │
        │  ┌─────────────┐    │     ┌───────────▼──────────┐   │
        │  │  desktop/   │    │     │ homeConfigurations   │   │
        │  │  config.nix │────┼─────│  - user@desktop      │   │
        │  └─────────────┘    │     │  - user@server       │   │
        │  ┌─────────────┐    │     └───────────┬──────────┘   │
        │  │  server/    │    │                 │              │
        │  │  config.nix │    │                 │              │
        │  └─────────────┘    │                 │              │
        └──────────┬───────────┘                 │              │
                   │                             │              │
                   │    ┌────────────────────────┴──────┐       │
                   │    │                               │       │
        ┌──────────▼────▼─────────┐         ┌──────────▼───────▼──┐
        │      modules/            │         │      home/           │
        │  ┌─────────────────┐    │         │  ┌──────────────┐   │
        │  │  desktop/       │    │         │  │ desktop.nix  │   │
        │  │  - default.nix  │    │         │  │ server.nix   │   │
        │  │  - wayland.nix  │    │         │  └──────┬───────┘   │
        │  └─────────────────┘    │         │         │           │
        │  ┌─────────────────┐    │         │  ┌──────▼───────┐   │
        │  │  server/        │    │         │  │  config/     │   │
        │  │  - default.nix  │    │         │  │  - hypr/     │   │
        │  └─────────────────┘    │         │  │  - ...       │   │
        │  ┌─────────────────┐    │         │  └──────────────┘   │
        │  │  applications/  │◄───┼─────────┤                     │
        │  │  - neovim.nix   │    │         │                     │
        │  │  - vscode.nix   │    │         │                     │
        │  │  - firefox.nix  │    │         │                     │
        │  └─────────────────┘    │         │                     │
        └─────────────────────────┘         └─────────────────────┘
```

## Component Responsibilities

### `flake.nix`
**Purpose**: Entry point and configuration orchestrator
- Defines inputs (nixpkgs, home-manager)
- Creates NixOS system configurations
- Creates standalone Home Manager configurations
- Ensures reproducibility through lock file

### `hosts/`
**Purpose**: Machine-specific system configuration
- Hardware-specific settings
- Boot loader configuration
- Hostname, timezone, users
- Imports relevant modules based on machine type

**Files**:
- `desktop/configuration.nix` - Desktop system config
- `server/configuration.nix` - Server system config
- `hardware-configuration.nix.example` - Template for hardware config

### `modules/`
**Purpose**: Reusable NixOS system modules
- System-level configuration
- Service definitions
- Package installations
- Can be mixed and matched

**Structure**:
- `desktop/` - Desktop environment modules
  - `default.nix` - Display manager, services
  - `wayland.nix` - Wayland/Hyprland setup
- `server/` - Server modules
  - `default.nix` - SSH, firewall, minimal tools
- `applications/` - Application configurations
  - `neovim.nix` - Editor setup
  - `vscode.nix` - IDE setup
  - `firefox.nix` - Browser setup

### `home/`
**Purpose**: User environment configuration (Home Manager)
- User-specific settings
- Dotfiles management
- User package installations
- Works with or without NixOS

**Files**:
- `desktop.nix` - Desktop user environment
- `server.nix` - Server user environment
- `config/` - Application configuration files
  - `hypr/hyprland.conf` - Window manager config

## Data Flow

### NixOS System Build
```
1. User runs: sudo nixos-rebuild switch --flake .#desktop
2. Nix reads flake.nix
3. Loads desktop from nixosConfigurations
4. Imports hosts/desktop/configuration.nix
5. Host imports modules/desktop/
6. Modules install packages and configure services
7. Home Manager is invoked for user environment
8. Home imports application modules
9. System is built and activated
```

### Standalone Home Manager Build
```
1. User runs: home-manager switch --flake .#user@desktop
2. Nix reads flake.nix
3. Loads user@desktop from homeConfigurations
4. Imports home/desktop.nix
5. Home config imports application modules
6. User environment is built and activated
```

## Design Principles

### 1. Modularity
- Each component has a single responsibility
- Modules can be mixed and matched
- Easy to add/remove features

### 2. Reusability
- Application modules work on both desktop and server
- Home configs work standalone or with NixOS
- Host configs are templates for new machines

### 3. Declarative
- Everything defined in code
- No manual configuration needed
- Reproducible across machines

### 4. Layered Architecture
```
Layer 4: Applications (neovim, vscode, firefox)
Layer 3: User Environment (home-manager)
Layer 2: System Modules (desktop, server)
Layer 1: Host Configuration (specific machines)
Layer 0: Flake (orchestration)
```

## Extension Points

### Adding a New Application
1. Create `modules/applications/myapp.nix`
2. Import in `home/desktop.nix` or `home/server.nix`

### Adding a New Host
1. Create `hosts/myhost/configuration.nix`
2. Add to `flake.nix` under `nixosConfigurations`

### Adding a New Module Type
1. Create `modules/category/mymodule.nix`
2. Import in relevant host configurations

### Adding a New Profile
1. Create `modules/profiles/myprofile.nix`
2. Import multiple modules for a specific use case

## Configuration Inheritance

```
flake.nix
  └─> hosts/desktop/configuration.nix
       ├─> modules/desktop/default.nix
       │    └─> modules/desktop/wayland.nix
       └─> home/desktop.nix (via home-manager)
            ├─> modules/applications/neovim.nix
            ├─> modules/applications/vscode.nix
            └─> modules/applications/firefox.nix
```

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Package Management | Nix | Reproducible packages |
| System Configuration | NixOS | Declarative OS |
| User Environment | Home Manager | Dotfile management |
| Window Manager | Hyprland | Wayland compositor |
| Status Bar | Waybar | System information |
| Launcher | Wofi | Application launcher |
| Terminal | Kitty | Modern terminal |
| Audio | PipeWire | Low-latency audio |

## Security Considerations

### Server Configuration
- SSH password authentication disabled
- Firewall enabled by default
- Root login disabled
- Only essential ports open

### Desktop Configuration
- Polkit for privilege elevation
- XDG portals for sandboxed access
- Wayland for better security than X11

## Performance Considerations

- PipeWire for low-latency audio
- Wayland for better performance than X11
- Minimal server configuration
- Lazy loading of services

## Future Extension Ideas

- Add Docker/Podman module
- Add development environment modules
- Add gaming module
- Add backup module
- Add secrets management (sops-nix/agenix)
- Add CI/CD for automatic builds
- Add multiple desktop profiles

## References

- [NixOS Module System](https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules)
- [Home Manager](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
