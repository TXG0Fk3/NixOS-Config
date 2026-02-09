{ config, pkgs, ...}:

{
  # FileSystems
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/STORAGE-WD";
    fsType = "ext4";
    options = [ "noatime" "errors=remount-ro" "nofail" "rw" ];
  };
}