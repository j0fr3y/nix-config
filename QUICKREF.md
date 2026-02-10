# NixOS Configuration - Quick Reference

## Schnellstart

```bash
# Hilfe anzeigen
./nixos.sh help

# Configuration aktivieren
./nixos.sh switch          # Verwendet aktuellen Hostname
./nixos.sh switch laptop1  # Für spezifischen Host

# Neues Gerät hinzufügen
./nixos.sh bootstrap
```

## Alle Befehle

| Befehl | Beschreibung |
|--------|-------------|
| `./nixos.sh switch [host]` | Configuration aktivieren |
| `./nixos.sh test [host]` | Testen ohne Reboot |
| `./nixos.sh build [host]` | Nur bauen, nicht aktivieren |
| `./nixos.sh bootstrap` | Neues Gerät einrichten |
| `./nixos.sh update` | Flake inputs aktualisieren |
| `./nixos.sh clean` | Alte Generationen löschen |
| `./nixos.sh list` | Alle Hosts anzeigen |
| `./nixos.sh check` | Configuration überprüfen |

## Ohne Script (direkt)

```bash
# Switch
sudo nixos-rebuild switch --flake .#laptop1

# Test
sudo nixos-rebuild test --flake .#laptop1

# Update
nix flake update

# Cleanup
sudo nix-collect-garbage -d
```

## Remote Deployment

```bash
# Von lokalem Rechner auf Server deployen
nixos-rebuild switch --flake .#server1 \
  --target-host user@server1 \
  --build-host localhost
```

## Neue Hardware hinzufügen

```bash
# Hardware-Config generieren
sudo nixos-generate-config --show-hardware-config > hosts/laptop1/hardware-configuration.nix

# Config erstellen
cp hosts/desktop/configuration.nix hosts/laptop1/configuration.nix
# → hostname anpassen

# Zu flake.nix hinzufügen
# laptop1 = mkSystem "laptop1" "desktop";

# Aktivieren
./nixos.sh switch laptop1
```

## Struktur

```
├── nixos.sh              ← Hauptscript (kein make nötig!)
├── flake.nix             ← Host-Definitionen
├── hosts/
│   ├── common/           ← Gemeinsame Config
│   ├── laptop1/          ← Host-spezifisch
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── server1/
├── modules/
│   ├── desktop/          ← Desktop-Module
│   └── server/           ← Server-Module
└── home/
    ├── desktop.nix       ← Home-Manager Desktop
    └── server.nix        ← Home-Manager Server
```
