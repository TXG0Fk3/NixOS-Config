{ config, pkgs, system-modules, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      linuxPackages_xanmod_latest = super.linuxPackages_xanmod_latest.extend (kself: ksuper: {
        rtl8852cu = ksuper.callPackage (system-modules + "/packages/rtl8852cu.nix") { };
      });
    })
  ];
}