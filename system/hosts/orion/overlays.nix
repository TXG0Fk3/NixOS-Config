{
  config,
  pkgs,
  system-modules,
  ...
}:

{
  nixpkgs.overlays = [
    (self: super: {
      linuxPackages_betelgeuse = self.linuxPackagesFor (
        self.callPackage (system-modules + "/packages/kernel/linuxBetelgeuse.nix") { }
      );
      dmemcg-booster = self.callPackage (system-modules + "/packages/dmemcg-booster.nix") { };
    })
  ];
}
