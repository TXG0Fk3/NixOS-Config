{
  inputs,
  system-modules,
  ...
}:

{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    (self: _: {
      linuxPackages_betelgeuse = self.linuxPackagesFor (
        import (system-modules + "/packages/kernel/linuxBetelgeuse.nix") {
          inherit (self) lib cachyosKernels;
        }
      );
      dmemcg-booster = self.callPackage (system-modules + "/packages/dmemcg-booster.nix") { };
    })
  ];
}
