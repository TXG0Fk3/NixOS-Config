{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.homelab.backup;
  btrfsRoot = "/var/lib/btrfs-cloud-wd";
  stagingDir = "/run/hydra-backup";

  prepareScript = pkgs.writeShellScript "hydra-backup-prepare" ''
    set -euo pipefail

    if [ -e "${btrfsRoot}/@snap-cloud" ]; then
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "${btrfsRoot}/@snap-cloud"
    fi
    if [ -e "${btrfsRoot}/@snap-forgejo" ]; then
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "${btrfsRoot}/@snap-forgejo"
    fi

    ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r "${btrfsRoot}/@cloud" "${btrfsRoot}/@snap-cloud"
    ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r "${btrfsRoot}/@forgejo" "${btrfsRoot}/@snap-forgejo"

    dump_sqlite_dir() {
      local src_dir="$1"
      local dst_dir="$2"
      [ -d "$src_dir" ] || return 0
      mkdir -p "$dst_dir"
      while IFS= read -r -d "" db; do
        if ${pkgs.coreutils}/bin/head -c 16 "$db" 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q "^SQLite format 3"; then
          local rel="''${db#"$src_dir"/}"
          mkdir -p "$dst_dir/$(${pkgs.coreutils}/bin/dirname "$rel")"
          ${pkgs.sqlite}/bin/sqlite3 "$db" ".timeout 5000" ".backup '$dst_dir/$rel'"
        fi
      done < <(${pkgs.findutils}/bin/find "$src_dir" -type f \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) -print0)
    }

    rm -rf "${stagingDir}/db"
    dump_sqlite_dir "/mnt/forgejo" "${stagingDir}/db/forgejo"
    dump_sqlite_dir "/var/lib/containers/filebrowser/data" "${stagingDir}/db/filebrowser"
    dump_sqlite_dir "/var/lib/containers/jellyfin/config/data" "${stagingDir}/db/jellyfin"
    dump_sqlite_dir "/var/lib/containers/crafty/config" "${stagingDir}/db/crafty"
    dump_sqlite_dir "/var/lib/radarr/.config/Radarr" "${stagingDir}/db/radarr"
    dump_sqlite_dir "/var/lib/sonarr/.config/NzbDrone" "${stagingDir}/db/sonarr"
    dump_sqlite_dir "/var/lib/prowlarr" "${stagingDir}/db/prowlarr"
  '';

  cleanupScript = pkgs.writeShellScript "hydra-backup-cleanup" ''
    set -u

    ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "${btrfsRoot}/@snap-cloud" 2>/dev/null || true
    ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "${btrfsRoot}/@snap-forgejo" 2>/dev/null || true

    rm -rf "${stagingDir}/db"
  '';

  notifyScript = pkgs.writeShellScript "hydra-backup-notify" ''
    set -euo pipefail
    status="''${1:-failure}"
    webhook=$(<"${cfg.discordWebhookFile}")

    if [ "$status" = "success" ]; then
      title="Backup Succeeded on ${config.networking.hostName}"
      color=3800968
      desc="Snapshot created, pruned, and verified successfully."
    else
      title="Backup Failed on ${config.networking.hostName}"
      color=16729440
      desc="Check logs with: journalctl -u restic-backups-hydra.service -n 50"
    fi

    payload=$(${pkgs.jq}/bin/jq -n \
      --arg title "$title" \
      --argjson color "$color" \
      --arg repo "${cfg.repository}" \
      --arg unit "restic-backups-hydra.service" \
      --arg desc "$desc" \
      '{
        username: "Hydra Backup",
        embeds: [{
          title: $title,
          color: $color,
          fields: [
            { name: "Service", value: $unit, inline: true },
            { name: "Repository", value: $repo, inline: true }
          ],
          description: $desc
        }]
      }')
    ${pkgs.curl}/bin/curl -fsSL -H "Content-Type: application/json" -d "$payload" "$webhook"
  '';

  backupNow = pkgs.writeShellScriptBin "hydra-backup" ''
    set -euo pipefail
    echo "Starting Hydra backup (restic-backups-hydra.service)..."
    if [ "''${EUID:-$(id -u)}" -eq 0 ]; then
      exec systemctl start restic-backups-hydra.service
    fi
    exec sudo systemctl start restic-backups-hydra.service
  '';
in
{
  options.services.homelab.backup = {
    enable = lib.mkEnableOption "automated encrypted backups to Google Drive via Restic and Rclone";

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to environment file containing RESTIC_PASSWORD and RCLONE_CONFIG_GDRIVE_* secrets.";
    };

    discordWebhookFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional path to Discord webhook URL file for backup notifications.";
    };

    repository = lib.mkOption {
      type = lib.types.str;
      default = "rclone:gdrive:/04_Backups/Hydra";
      description = "Restic repository location.";
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems.${btrfsRoot} = {
      device = "/dev/disk/by-label/CLOUD-WD";
      fsType = "btrfs";
      options = [
        "subvolid=5"
        "noatime"
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
      ];
    };

    services.restic.backups.hydra = {
      inherit (cfg) repository environmentFile;
      initialize = true;

      rcloneConfig = {
        type = "drive";
        scope = "drive.file";
      };

      rcloneOptions = {
        tpslimit = "10";
        drive-chunk-size = "32M";
        drive-use-trash = false;
        fast-list = true;
      };

      timerConfig = {
        OnCalendar = "*-*-1/2 04:00:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };

      extraBackupArgs = [ "--pack-size=64" ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      checkOpts = [ "--read-data-subset=1%" ];

      backupPrepareCommand = "${prepareScript}";
      backupCleanupCommand = "${cleanupScript}";

      paths = [
        "${btrfsRoot}/@snap-cloud"
        "${btrfsRoot}/@snap-forgejo"
        "${stagingDir}/db"
        "/var/lib/containers/crafty/servers"
        "/var/lib/containers/crafty/config"
        "/var/lib/containers/filebrowser/data"
        "/var/lib/containers/jellyfin/config"
        "/var/lib/containers/syncthing"
        "/var/lib/containers/qbittorrent"
        "/var/lib/radarr/.config/Radarr"
        "/var/lib/sonarr/.config/NzbDrone"
        "/var/lib/prowlarr"
      ];

      exclude = [
        "${btrfsRoot}/@snap-forgejo/**/*.db*"
        "${btrfsRoot}/@snap-forgejo/**/*.sqlite*"
        "/var/lib/containers/filebrowser/data/database.sqlite*"
        "/var/lib/containers/jellyfin/config/data/**/*.db*"
        "/var/lib/containers/jellyfin/config/transcodes"
        "/var/lib/containers/crafty/config/**/*.sqlite*"
        "/var/lib/radarr/.config/Radarr/*.db*"
        "/var/lib/radarr/.config/Radarr/logs"
        "/var/lib/radarr/.config/Radarr/Sentry"
        "/var/lib/sonarr/.config/NzbDrone/*.db*"
        "/var/lib/sonarr/.config/NzbDrone/logs"
        "/var/lib/sonarr/.config/NzbDrone/Sentry"
        "/var/lib/prowlarr/*.db*"
        "/var/lib/prowlarr/logs"
        "/var/lib/prowlarr/Sentry"
      ];
    };

    environment.systemPackages = [ backupNow ];

    systemd.services.restic-backups-hydra = {
      path = [ pkgs.rclone ];
      environment = {
        GOGC = "25";
        GOMEMLIMIT = "2GiB";
      };
      unitConfig = {
        RequiresMountsFor = [
          "/mnt/cloud"
          "/mnt/forgejo"
          btrfsRoot
        ];
        OnSuccess = lib.optional (cfg.discordWebhookFile != null) "restic-backup-notify@success.service";
        OnFailure = lib.optional (cfg.discordWebhookFile != null) "restic-backup-notify@failure.service";
      };
    };

    systemd.services."restic-backup-notify@" = lib.mkIf (cfg.discordWebhookFile != null) {
      description = "Send Discord notification for Hydra backup (%i)";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${notifyScript} %i";
      };
    };
  };
}
