{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kando

    xsel # Required for the “Paste Text” feature
  ];
}
