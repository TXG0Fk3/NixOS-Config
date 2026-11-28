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
    udev.extraRules = ''
      # NVMe SSDs
      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
      # SATA/SAS SSDs
      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="adios"
      # Rotational HDDs
      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      # Hide Windows SSD from Nautilus / udisks2
      SUBSYSTEM=="block", ENV{ID_SERIAL_SHORT}=="50026B7784F18F1B", ENV{UDISKS_IGNORE}="1"
    '';
  };
}
