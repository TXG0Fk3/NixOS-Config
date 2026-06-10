{ config, pkgs, ... }:

{
  fileSystems."/mnt/cloud" = {
    device = "/dev/disk/by-label/CLOUD-WD";
    fsType = "btrfs";
    options = [
      "subvol=@cloud"
      "compress=zstd:3"
      "noatime"
      "nofail"
      "space_cache=v2"
    ];
  };

  fileSystems."/mnt/forgejo" = {
    device = "/dev/disk/by-label/CLOUD-WD";
    fsType = "btrfs";
    options = [
      "subvol=@forgejo"
      "compress=zstd:3"
      "noatime"
      "nofail"
      "space_cache=v2"
      "autodefrag"
    ];
  };

  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-label/MEDIA-WD";
    fsType = "xfs";
    options = [
      "noatime"
      "nofail"
    ];
  };

  #fileSystems."/mnt/scratch" = {
  #  device = "/dev/disk/by-label/SCRATCH-SM";
  #  fsType = "xfs";
  #  options = [
  #    "noatime"
  #    "nofail"
  #  ];
  #};

  environment.systemPackages = with pkgs; [
    hdparm
    smartmontools
    idle3tools
  ];

  services = {
    fstrim.enable = true;
    smartd = {
      enable = true;
      notifications.wall.enable = true;
    };
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/mnt/cloud" ];
    };
  };
}
