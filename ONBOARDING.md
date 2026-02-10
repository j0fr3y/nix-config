# Quick Onboarding Guide

Neues Gerät in unter 5 Minuten zur Config hinzufügen!

## Option 1: Automatisch (Empfohlen) 🚀

Auf dem **neuen** NixOS Gerät:

```bash
# 1. Clone deine Config
git clone <your-repo> /etc/nixos
cd /etc/nixos

# 2. Bootstrap-Script ausführen
make bootstrap

# 3. Hostname zur flake.nix hinzufügen (siehe unten)

# 4. Fertig!
sudo nixos-rebuild switch --flake .#<dein-hostname>
```

## Option 2: Manuell

### 1. Hardware-Konfiguration generieren

```bash
cd /etc/nixos
sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

### 2. Configuration erstellen

Erstelle `hosts/<hostname>/configuration.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common                    # Gemeinsame Config
    ../../modules/desktop        # oder /server
  ];

  networking.hostName = "<hostname>";
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Host-spezifische Anpassungen hier
}
```

### 3. Zur flake.nix hinzufügen

Öffne `flake.nix` und füge deinen Host hinzu:

```nix
nixosConfigurations = {
  # Existing hosts...
  
  laptop1 = mkSystem "laptop1" "desktop";
  laptop2 = mkSystem "laptop2" "desktop";
  laptop3 = mkSystem "laptop3" "desktop";
  server1 = mkSystem "server1" "server";
};
```

### 4. Aktivieren

```bash
sudo nixos-rebuild switch --flake .#laptop1
```

## Struktur

```
nix-config/
├── hosts/
│   ├── common/              # Gemeinsame Config (SSH, Zeitzone, etc.)
│   ├── laptop1/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── laptop2/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── server1/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── desktop/             # Desktop-spezifische Module (Hyprland, etc.)
│   └── server/              # Server-spezifische Module
└── home/
    ├── desktop.nix          # Home-Manager für Desktop
    └── server.nix           # Home-Manager für Server
```

## Nützliche Befehle

```bash
make help                    # Alle Befehle anzeigen
make bootstrap              # Neuen Host erstellen (interaktiv)
make list-hosts             # Alle konfigurierten Hosts auflisten
make switch HOSTNAME=laptop1 # Zu Config wechseln
make update                 # Flake inputs aktualisieren
```

## Tipps

- **Host-spezifische** Anpassungen in `hosts/<hostname>/configuration.nix`
- **Gemeinsame** Settings in `hosts/common/default.nix`
- **Desktop/Server** Features in `modules/desktop` bzw. `modules/server`
- **User-Config** in `home/desktop.nix` bzw. `home/server.nix`

## Remote Deployment

Neuen Server aus der Ferne deployen:

```bash
# SSH Key hinterlegen
ssh-copy-id user@new-server

# Remote deployen
nixos-rebuild switch --flake .#server1 \
  --target-host user@new-server \
  --build-host localhost
```
