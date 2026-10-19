{
  description = "TXG0Fk3 Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    artcraft.url = "github:ipeglin/artcraft-nix";
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
      users = ./home-manager/users;
      colors = import ./home-manager/colors.nix;

      sysArgs = { inherit inputs secrets system-modules; };
      homeArgs = {
        inherit
          inputs
          secrets
          home-modules
          users
          colors
          ;
      };
    in
    {
      nixosConfigurations = {
        # Orion
        Orion = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = sysArgs;
          modules = [
            ./system/hosts/orion
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                extraSpecialArgs = homeArgs;
                users.TXG0Fk3 = import ./home-manager/users/txg0fk3/orion;
              };
            }
          ];
        };

        # Phoenix
        Phoenix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = sysArgs;
          modules = [
            ./system/hosts/phoenix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                extraSpecialArgs = homeArgs;
                users.TXG0Fk3 = import ./home-manager/users/txg0fk3/phoenix.nix;
              };
            }
          ];
        };

        # Hydra
        Hydra = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = sysArgs;
          modules = [
            ./system/hosts/hydra
            sops-nix.nixosModules.sops
          ];
        };

        # Symbiote
        Symbiote = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = sysArgs;
          modules = [
            ./system/hosts/symbiote
            nixos-wsl.nixosModules.default
          ];
        };
      };
    };
}
