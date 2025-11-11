{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (prismlauncher.override {
      jdks = [
        javaPackages.compiler.temurin-bin.jre-21
        javaPackages.compiler.temurin-bin.jre-17
      ];
    })
  ];
}