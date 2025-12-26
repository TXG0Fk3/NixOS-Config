{ config, pkgs, system-modules, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      linuxPackages_zen = super.linuxPackages_zen.extend (kself: ksuper: {
        rtl8852cu = ksuper.callPackage (system-modules + "/packages/rtl8852cu.nix") { };
      });
    })
  ];
}