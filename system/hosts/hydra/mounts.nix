{ config, pkgs, ... }:

{
  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-label/MEDIA-SM";
    fsType = "xfs";
    options = [
      "noatime"
      "nofail"
    ];
  };

  fileSystems."/mnt/scratch" = {
    device = "/dev/disk/by-label/SCRATCH-SM";
    fsType = "xfs";
    options = [
      "noatime"
      "nofail"
    ];
  };

  environment.systemPackages = with pkgs; [
    hdparm
    smartmontools
    idle3tools
  ];

  services.smartd = {
    enable = true;
    notifications.wall.enable = true;
  };

  powerManagement.powerUpCommands = ''
    ${pkgs.hdparm}/sbin/hdparm -B 254 -S 0 /dev/disk/by-id/ata-SAMSUNG_HM500JI_S227J56B710852
  '';
}
