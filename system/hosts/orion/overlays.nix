{
  config,
  pkgs,
  system-modules,
  ...
}:

{
  nixpkgs.overlays = [
    (self: super: {
      linuxPackages_latest = super.linuxPackages_latest.extend (
        kself: ksuper: {
          rtw89-morrownr = ksuper.callPackage (system-modules + "/packages/rtw89.nix") { };
        }
      );
    })
  ];
}
