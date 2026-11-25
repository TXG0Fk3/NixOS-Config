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
    edged = {
      url = "github:TXG0Fk3/Edged";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    artcraft.url = "github:TXG0Fk3/artcraft-nix";
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      home-manager,
      sops-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      secrets = ./secrets;
      system-modules = ./system/modules;
      home-modules = ./home-manager/modules;
      users = ./home-manager/users;
      colors = import ./colors.nix;

      sysArgs = {
        inherit
          inputs
          secrets
          system-modules
          colors
          ;
      };
      homeArgs = {
        inherit
          inputs
          secrets
          home-modules
          users
          colors
          ;
      };

      mkHost =
        {
          host,
          modules ? [ ],
          homeUser ? null,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = sysArgs;
          modules = [
            host
          ]
          ++ modules
          ++ nixpkgs.lib.optionals (homeUser != null) [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = homeArgs;
                users.TXG0Fk3 = import homeUser;
              };
            }
          ];
        };
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          nixfmt
          statix
          deadnix
          sops
          lua
        ];
      };

      checks.${system} = import ./checks.nix { inherit pkgs; };

      nixosConfigurations = {
        # Orion
        Orion = mkHost {
          host = ./system/hosts/orion;
          homeUser = ./home-manager/users/txg0fk3/orion;
        };

        # Phoenix
        Phoenix = mkHost {
          host = ./system/hosts/phoenix;
          homeUser = ./home-manager/users/txg0fk3/phoenix.nix;
        };

        # Hydra
        Hydra = mkHost {
          host = ./system/hosts/hydra;
          modules = [ sops-nix.nixosModules.sops ];
        };

        # Symbiote
        Symbiote = mkHost {
          host = ./system/hosts/symbiote;
          modules = [ nixos-wsl.nixosModules.default ];
        };
      };
    };
}
