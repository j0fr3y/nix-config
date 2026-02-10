{
  description = "Meine NixOS Server Infrastruktur";

  inputs = {
    # Offizielles NixOS Paket-Repository (Stable)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      
      # Hier wird dein erster Server definiert
      # Der Name hier (z.B. "mein-server") muss dem Hostnamen entsprechen
      mein-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/mein-server/configuration.nix
        ];
      };

    };
  };
}
