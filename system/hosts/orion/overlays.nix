{ config, pkgs, system-modules, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      linuxPackages_zen = super.linuxPackages_zen.extend (kself: ksuper: {
        rtw89-morrownr = ksuper.callPackage (system-modules + "/packages/rtw89.nix") { };
      });
    })
  ];
}