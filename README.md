# Mein NixOS Server Config Repo

Ein minimalistisches Setup, um NixOS Server mit Nix Flakes zu verwalten.

## Repository Struktur

```
.
├── flake.nix                  # Entry-Point und Definition aller Server
└── hosts/
    └── mein-server/           # Konfiguration für einen spezifischen Server
        ├── configuration.nix          # Hauptkonfiguration
        └── hardware-configuration.nix # Hardware-Infos (Disks, CPU etc.)
```

## Installation auf einem neuen Server

1. **NixOS normal installieren** (z.B. ISO booten, partionieren, `nixos-generate-config`).
2. Kopiere die generierte `hardware-configuration.nix` von `/mnt/etc/nixos/` in dieses Repo unter `hosts/<neuer-server>/`.
3. Kopiere `hosts/mein-server/configuration.nix` zu `hosts/<neuer-server>/configuration.nix` und passe sie an (Hostname ändern!).
4. Registriere den neuen Server in der `flake.nix`:

```nix
    nixosConfigurations = {
      # ... andere Server ...
      
      neuer-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/neuer-server/configuration.nix ];
      };
    };
```

5. Deployen (auf dem Server, im Ordner dieses Repos):
   ```bash
   sudo nixos-rebuild switch --flake .#neuer-server
   ```
