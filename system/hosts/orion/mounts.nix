{ ... }:

{
  # FileSystems
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-label/SSD";
    fsType = "f2fs";
    options = [
      "noatime"
      "lazytime"
      "nofail"
      "x-gvfs-show"
    ];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-label/HDD";
    fsType = "ext4";
    options = [
      "noatime"
      "lazytime"
      "nofail"
      "x-gvfs-show"
      "x-systemd.automount"
    ];
  };

  services = {
    fstrim.enable = true;
  };
}
