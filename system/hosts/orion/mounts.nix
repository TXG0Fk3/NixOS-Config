{ config, pkgs, ...}:

{
  # FileSystems
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/7f04f633-d8ee-4767-b570-46b3af240565";
    fsType = "f2fs";
    options = [ "noatime" "nodiratime" "discard" "lazytime" "compress_chksum" "x-gvfs-show" "rw" ];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/927b9270-9063-4dc9-b678-6ecfd8aa6794";
    fsType = "ext4";
    options = [ "relatime" "nofail" "x-gvfs-show" "rw" ];
  };
}