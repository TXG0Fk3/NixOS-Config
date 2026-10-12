{ pkgs, ... }:

{
  # Systemd
  systemd.packages = [ pkgs.dmemcg-booster ];
  systemd.services.dmemcg-booster-system.wantedBy = [ "multi-user.target" ];
  systemd.user.services.dmemcg-booster-user.wantedBy = [ "default.target" ];

  systemd.services.dmem-low = {
    description = "Keep dmem.low raised for Steam/Bottles cgroups";
    wantedBy = [ "multi-user.target" ];
    after = [ "dmemcg-booster-system.service" ];
    serviceConfig.Restart = "always";
    script = ''
      root=/sys/fs/cgroup
      while true; do
        cap=$(<"$root/dmem.capacity")
        for scope in \
          "$root"/user.slice/user-*.slice/user@*.service/app.slice/app-*steam*.scope \
          "$root"/user.slice/user-*.slice/user@*.service/app.slice/*/app-*steam*.scope \
          "$root"/user.slice/user-*.slice/user@*.service/app.slice/app-*bottles*.scope \
          "$root"/user.slice/user-*.slice/user@*.service/app.slice/*/app-*bottles*.scope
        do
          [ -d "$scope" ] || continue
          p="$scope"
          while [ "$p" != "$root" ]; do
            { printf '%s\n' "$cap" > "$p/dmem.low"; } 2>/dev/null || true
            p=''${p%/*}
          done
        done
        sleep 5
      done
    '';
  };
}
