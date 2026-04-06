{
  description = "TXG0Fk3 Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      sops-nix,
      ...
    }@inputs:
    let
      secrets = ./secrets;
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
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs secrets home-modules; };
                users.TXG0Fk3 = import ./home-manager/users/txg0fk3/orion.nix;
              };
            }
          ];
        };

        # Phoenix
        Phoenix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs system-modules; };
          modules = [
            ./system/hosts/phoenix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs home-modules; };
                users.TXG0Fk3 = import ./home-manager/users/txg0fk3/phoenix.nix;
              };
            }
          ];
        };

        # Hydra
        Hydra = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs secrets system-modules; };
          modules = [
            ./system/hosts/hydra
            sops-nix.nixosModules.sops
          ];
        };

        # Symbiote
        Symbiote = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./system/hosts/symbiote
            nixos-wsl.nixosModules.default
          ];
        };
      };
    };
}
