{ config, pkgs, ... }:

let
  smartdDiscord = pkgs.writeShellScript "smartd-discord" ''
    cat > /dev/null
    webhook=$(<"${config.sops.secrets."discord-webhook".path}")
    payload=$(${pkgs.jq}/bin/jq -n \
      --arg title "SMART Alert on ${config.networking.hostName}: $SMARTD_SUBJECT" \
      --arg device "$SMARTD_DEVICESTRING" \
      --arg type "$SMARTD_FAILTYPE" \
      --arg msg "$SMARTD_FULLMESSAGE" \
      '{
        username: "Hydra SMART",
        embeds: [{
          title: $title,
          color: 16729440,
          fields: [
            { name: "Device", value: $device, inline: true },
            { name: "Failure Type", value: $type, inline: true },
            { name: "Details", value: $msg }
          ]
        }]
      }')
    ${pkgs.curl}/bin/curl -fsSL -H "Content-Type: application/json" -d "$payload" "$webhook"
  '';
in
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

  fileSystems."/mnt/media2" = {
    device = "/dev/disk/by-label/MEDIA2-WD";
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

  services.udev.extraRules = ''
    KERNEL=="sd[a-z]", ENV{ID_SERIAL_SHORT}=="WD-WXA2A90F6V75", RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 -M 254 %N"
    KERNEL=="sd[a-z]", ENV{ID_SERIAL_SHORT}=="WD-WXK2AC0RCVLC", RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 -M 254 %N"
  '';

  services = {
    fstrim.enable = true;
    smartd = {
      enable = true;
      defaults.monitored = "-a -o on -s (S/../.././02|L/../../7/04)";
      notifications = {
        wall.enable = true;
        mail = {
          enable = true;
          mailer = "${smartdDiscord}";
        };
      };
    };
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/mnt/cloud" ];
    };
  };
}
