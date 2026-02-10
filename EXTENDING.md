# Extending the Configuration

This document explains how to extend and customize the configuration.

## Adding New Modules

### Creating an Application Module

1. Create a new file in `modules/applications/`:

```nix
# modules/applications/myapp.nix
{ config, pkgs, lib, ... }:

{
  # For Home Manager programs
  programs.myapp = {
    enable = true;
    settings = {
      # app-specific settings
    };
  };

  # Or for system-level packages
  home.packages = with pkgs; [
    myapp
  ];
}
```

2. Import it in your home configuration:

```nix
# home/desktop.nix
imports = [
  ../modules/applications/myapp.nix
  # ... other imports
];
```

### Creating a Service Module

For system-level services:

```nix
# modules/services/myservice.nix
{ config, pkgs, lib, ... }:

{
  services.myservice = {
    enable = true;
    # service configuration
  };
  
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
```

Import in host configuration:

```nix
# hosts/server/configuration.nix
imports = [
  ../../modules/services/myservice.nix
  ../../modules/server
];
```

## Common Extensions

### Adding Docker

```nix
# modules/development/docker.nix
{ config, pkgs, lib, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
  
  users.users.user.extraGroups = [ "docker" ];
}
```

### Adding Gaming Support

```nix
# modules/desktop/gaming.nix
{ config, pkgs, lib, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    lutris
    wine
    winetricks
  ];
}
```

### Adding Development Tools

```nix
# modules/development/tools.nix
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Version control
    git
    gh
    
    # Languages
    python3
    nodejs
    go
    rustc
    cargo
    
    # Tools
    docker-compose
    kubectl
    terraform
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

### Adding a Web Server

```nix
# modules/services/nginx.nix
{ config, pkgs, lib, ... }:

{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    
    virtualHosts."example.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/example.com";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  
  security.acme = {
    acceptTerms = true;
    defaults.email = "your.email@example.com";
  };
}
```

## Organizing Multiple Hosts

### Creating Environment-Specific Modules

```nix
# modules/profiles/workstation.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ../desktop
    ../applications/vscode.nix
    ../development/docker.nix
  ];
}

# modules/profiles/laptop.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ../desktop
  ];

  # Laptop-specific settings
  services.tlp.enable = true;
  powerManagement.enable = true;
}
```

Then in your host:

```nix
# hosts/mylaptop/configuration.nix
imports = [
  ./hardware-configuration.nix
  ../../modules/profiles/laptop.nix
];
```

## Using nixpkgs Overlays

Create overlays to modify or add packages:

```nix
# overlays/default.nix
{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      # Modify existing package
      mypackage = super.mypackage.overrideAttrs (old: {
        version = "custom";
      });
      
      # Add custom package
      my-custom-tool = super.callPackage ./packages/my-custom-tool.nix {};
    })
  ];
}
```

## Using Home Manager Modules

Home Manager has many built-in modules. Examples:

### Alacritty Terminal

```nix
programs.alacritty = {
  enable = true;
  settings = {
    font.size = 12;
    font.normal.family = "JetBrains Mono";
    colors.primary.background = "0x1e1e2e";
  };
};
```

### Tmux

```nix
programs.tmux = {
  enable = true;
  shortcut = "a";
  keyMode = "vi";
  terminal = "screen-256color";
  plugins = with pkgs.tmuxPlugins; [
    sensible
    yank
    resurrect
  ];
};
```

### Zsh

```nix
programs.zsh = {
  enable = true;
  enableCompletion = true;
  enableAutosuggestions = true;
  syntaxHighlighting.enable = true;
  
  oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";
    plugins = [ "git" "docker" "kubectl" ];
  };
};
```

## Managing Secrets

For secrets management, consider using:

### sops-nix

```nix
# In flake.nix inputs
sops-nix.url = "github:Mic92/sops-nix";

# In module
imports = [ sops-nix.nixosModules.sops ];

sops.defaultSopsFile = ./secrets/secrets.yaml;
sops.secrets.example-key = {};
```

### agenix

```nix
# In flake.nix inputs
agenix.url = "github:ryantm/agenix";

# In module
imports = [ agenix.nixosModules.default ];

age.secrets.example-secret.file = ./secrets/example.age;
```

## Testing Changes

### Using Flake Outputs

Add development outputs to flake.nix:

```nix
outputs = { self, nixpkgs, ... }: {
  # Existing outputs...
  
  devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
    packages = with nixpkgs.legacyPackages.x86_64-linux; [
      nixfmt
      nil  # Nix LSP
    ];
  };
};
```

Enter dev shell:
```bash
nix develop
```

## References

- [NixOS Options Search](https://search.nixos.org/options)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Nix Package Search](https://search.nixos.org/packages)
