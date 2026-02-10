{
  description = "Modular NixOS & Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    # Helper function to create NixOS configuration
    mkSystem = hostname: type: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/${hostname}/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.user = import ./home/${type}.nix;
        }
      ];
    };
  in {
    # NixOS configurations
    nixosConfigurations = {
      # Legacy configurations (for backwards compatibility)
      desktop = mkSystem "desktop" "desktop";
      server = mkSystem "server" "server";

      # Add your laptops and servers here:
      # Example: laptop1 = mkSystem "laptop1" "desktop";
      # Example: laptop2 = mkSystem "laptop2" "desktop";
      # Example: laptop3 = mkSystem "laptop3" "desktop";
      # Example: server1 = mkSystem "server1" "server";
    };

    # Standalone home-manager configuration for non-NixOS systems
    homeConfigurations = {
      "user@desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home/desktop.nix ];
      };

      "user@server" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home/server.nix ];
      };
    };
  };
}
