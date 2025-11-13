{
  description = "TXG0Fk3 Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = { self, nixpkgs, home-manager, ...}@inputs:
  let
    system-modules = ./system/modules;
    home-modules = ./home-manager/modules;
  in
  {  
    nixosConfigurations = {
      # Orion
      Orion = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs system-modules; };
        modules = [
          ./system/hosts/orion
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs home-modules; };
              users.TXG0Fk3 = import ./home-manager/users/txg0fk3.nix;
            };
          }
        ];
      };

      # Hydra
      Hydra = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs system-modules; };
        modules = [ ./system/hosts/hydra ];
      };
    };
  };
}