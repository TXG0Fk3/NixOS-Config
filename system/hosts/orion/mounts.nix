{ config, pkgs, ...}:

{
  # FileSystems
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-label/SSD";
    fsType = "f2fs";
    options = [ "noatime" "lazytime" "compress_chksum" "x-gvfs-show" ];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-label/HDD";
    fsType = "ext4";
    options = [ "nofail" "x-gvfs-show" ];
  };
}
