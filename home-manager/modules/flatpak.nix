{inputs, config, ... }:

{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  services.flatpak = {
    update.auto = {
      enable = true;
      onCalendar = "daily";
    };
    packages = [
      "io.mrarm.mcpelauncher"
      "org.vinegarhq.Sober"
    ];
  };

  xdg.systemDirs.data = [
    "/var/lib/flatpak/exports/share"
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
  ];
}