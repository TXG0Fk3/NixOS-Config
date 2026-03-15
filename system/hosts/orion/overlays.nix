{
  config,
  pkgs,
  system-modules,
  ...
}:

{
  nixpkgs.overlays = [
    (
      self: super:
      let
        linuxBetelgeuse = import (system-modules + "/packages/kernel/linuxBetelgeuse.nix") {
          inherit (super)
            pkgs
            fetchurl
            fetchFromGitHub
            buildLinux
            lib
            ;
        };
        baseLinuxPackages = pkgs.linuxPackagesFor linuxBetelgeuse;
      in
      {
        linuxPackages_betelgeuse = baseLinuxPackages;
      }
    )
  ];
}
