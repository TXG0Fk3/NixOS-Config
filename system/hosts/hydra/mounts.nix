{ config, pkgs, ...}:

{
  # FileSystems
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/STORAGE-SM";
    fsType = "xfs";
    options = [ "noatime" "nofail" ];
  };

  environment.systemPackages = [ pkgs.hdparm ];

  powerManagement.powerUpCommands = ''
    ${pkgs.hdparm}/sbin/hdparm -B 254 -S 0 /dev/disk/by-id/ata-SAMSUNG_HM500JI_S227J56B710852
  '';
}