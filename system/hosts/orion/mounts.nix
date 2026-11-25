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
      "x-systemd.device-timeout=5s"
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
      "x-systemd.device-timeout=5s"
      "x-systemd.idle-timeout=10min"
    ];
  };

  services = {
    fstrim.enable = true;
    smartd = {
      enable = true;
      defaults.monitored = "-a -o on -s (S/../.././02|L/../../7/04)";
    };
  };
}
