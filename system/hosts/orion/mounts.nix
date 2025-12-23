{ config, pkgs, ...}:

{
  # FileSystems
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-label/SSD";
    fsType = "f2fs";
    options = [ "noatime" "nodiratime" "discard" "lazytime" "compress_chksum" "x-gvfs-show" "rw" ];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-label/HDD";
    fsType = "ext4";
    options = [ "relatime" "nofail" "x-gvfs-show" "rw" ];
  };
}
