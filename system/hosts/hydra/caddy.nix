{
  config,
  colors,
  lib,
  pkgs,
  ...
}:

let
  c = colors;
  domain = "hydra.txgfk.xyz";

  proxies = {
    jellyfin = {
      title = "Jellyfin";
      category = "Media";
      port = 8096;
    };
    radarr = {
      title = "Radarr";
      category = "Media";
      port = 7878;
    };
    sonarr = {
      title = "Sonarr";
      category = "Media";
      port = 8989;
    };
    prowlarr = {
      title = "Prowlarr";
      category = "Media";
      port = 9696;
    };
    qbittorrent = {
      title = "qBittorrent";
      category = "Downloads";
      port = 8080;
    };
    forgejo = {
      title = "Forgejo";
      category = "Development";
      port = 3000;
    };
    syncthing = {
      title = "Syncthing";
      category = "Storage";
      port = 8384;
      proxyOptions = "header_up Host localhost";
    };
    filebrowser = {
      title = "FileBrowser";
      category = "Storage";
      port = 8090;
    };
    crafty = {
      title = "Crafty";
      category = "Gaming";
      port = 8443;
      scheme = "https";
      proxyOptions = ''
        transport http {
          tls_insecure_skip_verify
        }
      '';
    };
  };

  mkReverseProxy =
    srv:
    let
      scheme = lib.optionalString ((srv.scheme or null) != null) "${srv.scheme}://";
      upstream = "${scheme}127.0.0.1:${toString srv.port}";
      opts = lib.removeSuffix "\n" (srv.proxyOptions or "");
      body = lib.concatMapStringsSep "\n" (line: if line == "" then "" else "  ${line}") (
        lib.splitString "\n" opts
      );
    in
    if (srv.proxyOptions or null) != null then
      ''
        reverse_proxy ${upstream} {
        ${body}
        }
      ''
    else
      ''
        reverse_proxy ${upstream}
      '';

  telemetryConfig = pkgs.writeText "hydra-telemetry-config.json" (
    builtins.toJSON {
      systemctl = "${config.systemd.package}/bin/systemctl";
      disks = [
        {
          mount = "/";
          label = "ROOT";
        }
        {
          mount = "/mnt/cloud";
          label = "CLOUD";
        }
        {
          mount = "/mnt/media";
          label = "MEDIA";
        }
        {
          mount = "/mnt/media2";
          label = "MEDIA2";
        }
        {
          mount = "/mnt/scratch";
          label = "SCRATCH";
        }
      ];
      services = lib.mapAttrsToList (
        name: srv:
        let
          isContainer = config.virtualisation.oci-containers.containers ? ${name};
        in
        {
          inherit name;
          inherit (srv) port;
          unit = if isContainer then "podman-${name}.service" else "${name}.service";
          autoStart =
            if isContainer then config.virtualisation.oci-containers.containers.${name}.autoStart else true;
        }
      ) proxies;
    }
  );

  telemetryScript = pkgs.writers.writePython3 "hydra-telemetry" { } ''
    import glob
    import json
    import os
    import socket
    import subprocess
    import time

    STATE_DIR = "/run/hydra-dashboard"
    PREV_CPU = os.path.join(STATE_DIR, "cpu-prev")
    OUT_FILE = os.path.join(STATE_DIR, "status.json")
    TMP_FILE = os.path.join(STATE_DIR, "status.json.tmp")

    with open(
        "${telemetryConfig}",
        encoding="utf-8",
    ) as f:
        cfg = json.load(f)


    def sample_cpu():
        with open("/proc/stat", encoding="utf-8") as f:
            parts = f.readline().split()
        vals = [int(x) for x in parts[1:9]]
        return sum(vals), vals[3] + vals[4]


    def read_cpu_percent():
        total, idle = sample_cpu()
        p_total, p_idle = 0, 0
        if os.path.exists(PREV_CPU):
            try:
                with open(PREV_CPU, encoding="utf-8") as f:
                    p_total, p_idle = (int(x) for x in f.read().split())
            except (ValueError, OSError):
                p_total = 0

        if p_total == 0:
            p_total, p_idle = total, idle
            time.sleep(0.1)
            total, idle = sample_cpu()

        dt = total - p_total
        di = idle - p_idle
        pct = max(0, min(100, round((dt - di) * 100 / dt))) if dt > 0 else 0

        with open(PREV_CPU, "w", encoding="utf-8") as f:
            f.write(f"{total} {idle}")
        return pct


    def read_cpu_temp():
        preferred = ("coretemp", "k10temp", "zenpower", "cpu_thermal")
        fallback = None
        for hw in sorted(glob.glob("/sys/class/hwmon/hwmon*")):
            name_path = os.path.join(hw, "name")
            temp_path = os.path.join(hw, "temp1_input")
            if not (os.path.isfile(name_path) and os.path.isfile(temp_path)):
                continue
            try:
                with open(name_path, encoding="utf-8") as nf:
                    name = nf.read().strip()
                with open(temp_path, encoding="utf-8") as tf:
                    temp_c = round(int(tf.read().strip()) / 1000)
                if name in preferred:
                    return temp_c
                if fallback is None and name == "acpitz":
                    fallback = temp_c
            except (ValueError, OSError):
                continue
        return fallback


    def read_meminfo():
        info = {}
        with open("/proc/meminfo", encoding="utf-8") as f:
            for line in f:
                k, v = line.split(":", 1)
                info[k] = int(v.strip().split()[0]) * 1024

        mem_total = info.get("MemTotal", 0)
        mem_avail = info.get("MemAvailable", info.get("MemFree", 0))
        mem_used = max(0, mem_total - mem_avail)
        mem_pct = round(mem_used * 100 / mem_total) if mem_total > 0 else 0

        swap_total = info.get("SwapTotal", 0)
        swap_free = info.get("SwapFree", 0)
        swap_used = max(0, swap_total - swap_free)
        swap_pct = round(swap_used * 100 / swap_total) if swap_total > 0 else 0

        return {
            "memory": {
                "used_bytes": mem_used,
                "total_bytes": mem_total,
                "percent": mem_pct,
            },
            "swap": {
                "used_bytes": swap_used,
                "total_bytes": swap_total,
                "percent": swap_pct,
            },
        }


    def read_disks():
        results = []
        for item in cfg["disks"]:
            mount = item["mount"]
            label = item["label"]
            try:
                if mount != "/" and not os.path.ismount(mount):
                    results.append({
                        "mount": mount,
                        "label": label,
                        "mounted": False,
                    })
                    continue
                st = os.statvfs(mount)
            except OSError:
                results.append({
                    "mount": mount,
                    "label": label,
                    "mounted": False,
                })
                continue

            total = st.f_blocks * st.f_frsize
            avail = st.f_bavail * st.f_frsize
            used = total - (st.f_bfree * st.f_frsize)
            denom = used + avail
            pct = round(used * 100 / denom) if denom > 0 else 0
            results.append({
                "mount": mount,
                "label": label,
                "mounted": True,
                "used_bytes": used,
                "avail_bytes": avail,
                "total_bytes": total,
                "percent": pct,
            })
        return results


    def check_port(port):
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=0.8):
                return True
        except OSError:
            return False


    def read_services():
        services = cfg["services"]
        units = [s["unit"] for s in services]
        try:
            res = subprocess.run(
                [cfg["systemctl"], "is-active", *units],
                capture_output=True,
                text=True,
                timeout=5,
            )
            states = res.stdout.splitlines()
        except (subprocess.SubprocessError, OSError):
            states = []

        statuses = {}
        for idx, srv in enumerate(services):
            unit_state = (
                states[idx].strip() if idx < len(states) else "unknown"
            )
            if unit_state == "active":
                status = "up" if check_port(srv["port"]) else "starting"
            elif unit_state == "activating":
                status = "starting"
            elif unit_state == "inactive" and not srv["autoStart"]:
                status = "off"
            else:
                status = "down"

            statuses[srv["name"]] = {
                "status": status,
                "autoStart": srv["autoStart"],
            }
        return statuses


    def main():
        os.makedirs(STATE_DIR, mode=0o755, exist_ok=True)
        with open("/proc/uptime", encoding="utf-8") as f:
            uptime = int(float(f.read().split()[0]))
        with open("/proc/loadavg", encoding="utf-8") as f:
            load = " ".join(f.read().split()[:3])

        mem = read_meminfo()
        data = {
            "updated_at": int(time.time()),
            "system": {
                "uptime": uptime,
                "load": load,
                "cpu": {
                    "percent": read_cpu_percent(),
                    "temp_c": read_cpu_temp(),
                },
                "memory": mem["memory"],
                "swap": mem["swap"],
            },
            "disks": read_disks(),
            "services": read_services(),
        }

        with open(TMP_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, separators=(",", ":"))
        os.chmod(TMP_FILE, 0o644)
        os.replace(TMP_FILE, OUT_FILE)


    if __name__ == "__main__":
        main()
  '';

  cards = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: srv: ''
      <a class="card" href="https://${name}.${domain}" data-service="${name}">
        <div class="card-head">
          <span class="category">${srv.category}</span>
          <span class="status" data-status="pending">·</span>
        </div>
        <span class="title">${srv.title}</span>
        <span class="host">${name}.${domain}</span>
      </a>
    '') proxies
  );

  dashboard = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta name="color-scheme" content="dark">
      <title>HYDRA</title>
      <style>
        :root {
          color-scheme: dark;
        }
        * {
          box-sizing: border-box;
          margin: 0;
          padding: 0;
          border-radius: 0;
          transition: none;
        }
        body {
          background-color: ${c.bg};
          color: ${c.fg};
          font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
          font-size: 14px;
          min-height: 100vh;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          padding: 32px 16px;
        }
        main {
          width: 100%;
          max-width: 760px;
          display: flex;
          flex-direction: column;
          gap: 12px;
        }
        header {
          display: flex;
          justify-content: space-between;
          align-items: baseline;
          flex-wrap: wrap;
          gap: 8px;
          border-bottom: 1px solid ${c.fg};
          padding-bottom: 10px;
        }
        .header-left,
        .header-right {
          display: flex;
          align-items: baseline;
          gap: 12px;
          flex-wrap: wrap;
        }
        h1 {
          font-size: 18px;
          font-weight: bold;
          letter-spacing: 2px;
        }
        .summary {
          font-size: 11px;
          font-weight: bold;
          letter-spacing: 0.5px;
          color: ${c.dim};
        }
        .summary[data-state="ok"] { color: ${c.green}; }
        .summary[data-state="warn"] { color: ${c.orange}; }
        .summary[data-state="down"] { color: ${c.red}; }
        .uptime {
          font-size: 12px;
          color: ${c.mid};
        }
        .domain {
          color: ${c.accent};
          font-size: 12px;
        }
        .panel {
          border: 1px solid ${c.layer3};
          background-color: ${c.bg};
          padding: 10px 12px;
        }
        .telemetry {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
          gap: 10px 16px;
        }
        .metric {
          display: flex;
          justify-content: space-between;
          align-items: baseline;
          font-size: 12px;
          gap: 8px;
        }
        .metric-label {
          color: ${c.dim};
          text-transform: uppercase;
          letter-spacing: 1px;
          font-size: 11px;
        }
        .metric-value {
          font-weight: bold;
          color: ${c.fg};
        }
        .metric-value[data-level="warn"] { color: ${c.orange}; }
        .metric-value[data-level="crit"] { color: ${c.red}; }
        .disks {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
          gap: 10px 20px;
        }
        .disk {
          display: flex;
          flex-direction: column;
          gap: 4px;
          font-size: 11px;
        }
        .disk-head {
          display: flex;
          justify-content: space-between;
          align-items: baseline;
          gap: 8px;
        }
        .disk-label {
          color: ${c.fg};
          font-weight: bold;
          letter-spacing: 0.5px;
        }
        .disk-mount {
          color: ${c.dim};
          font-weight: normal;
          margin-left: 6px;
        }
        .disk-info {
          color: ${c.mid};
        }
        .disk-info[data-level="warn"] { color: ${c.orange}; }
        .disk-info[data-level="crit"] { color: ${c.red}; }
        .bar {
          width: 100%;
          height: 5px;
          background-color: ${c.layer1};
          border: 1px solid ${c.layer3};
        }
        .bar-fill {
          height: 100%;
          background-color: ${c.accent};
        }
        .bar-fill[data-level="warn"] { background-color: ${c.orange}; }
        .bar-fill[data-level="crit"] { background-color: ${c.red}; }
        .grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
          gap: 12px;
          margin-top: 4px;
        }
        .card {
          display: flex;
          flex-direction: column;
          gap: 4px;
          background-color: ${c.bg};
          color: ${c.fg};
          border: 1px solid ${c.fg};
          padding: 14px;
          text-decoration: none;
        }
        .card[data-status="down"] {
          border-color: ${c.red};
        }
        .card-head {
          display: flex;
          justify-content: space-between;
          align-items: center;
          gap: 8px;
        }
        .card .category {
          font-size: 10px;
          color: ${c.accent};
          text-transform: uppercase;
          letter-spacing: 1px;
        }
        .card .status {
          font-size: 10px;
          font-weight: bold;
          letter-spacing: 0.5px;
          color: ${c.dim};
        }
        .card .status[data-status="up"] { color: ${c.green}; }
        .card .status[data-status="starting"] { color: ${c.orange}; }
        .card .status[data-status="off"] { color: ${c.dim}; }
        .card .status[data-status="down"] { color: ${c.red}; }
        .card .title {
          font-size: 15px;
          font-weight: bold;
        }
        .card .host {
          font-size: 11px;
          color: ${c.dim};
        }
        .card:hover,
        .card:focus-visible {
          background-color: ${c.fg};
          color: ${c.bg};
          border-color: ${c.fg};
          outline: none;
        }
        .card:hover .category,
        .card:hover .host,
        .card:hover .status,
        .card:focus-visible .category,
        .card:focus-visible .host,
        .card:focus-visible .status {
          color: ${c.bg};
        }
      </style>
    </head>
    <body>
      <main>
        <header>
          <div class="header-left">
            <h1>HYDRA</h1>
            <span id="summary" class="summary">CHECKING...</span>
          </div>
          <div class="header-right">
            <span id="uptime" class="uptime"></span>
            <span class="domain">${domain}</span>
          </div>
        </header>
        <section class="panel telemetry" id="telemetry">
          <div class="metric">
            <span class="metric-label">CPU</span>
            <span id="m-cpu" class="metric-value">--</span>
          </div>
          <div class="metric">
            <span class="metric-label">MEM</span>
            <span id="m-mem" class="metric-value">--</span>
          </div>
          <div class="metric">
            <span class="metric-label">SWAP</span>
            <span id="m-swap" class="metric-value">--</span>
          </div>
          <div class="metric">
            <span class="metric-label">LOAD</span>
            <span id="m-load" class="metric-value">--</span>
          </div>
        </section>
        <section class="panel disks" id="disks"></section>
        <div class="grid">
          ${cards}
        </div>
      </main>
      <script>
        (function () {
          function fmtBytes(b) {
            var tib = 1099511627776;
            var gib = 1073741824;
            if (b >= tib) return (b / tib).toFixed(1) + "T";
            return (b / gib).toFixed(b >= 100 * gib ? 0 : 1) + "G";
          }

          function fmtUptime(s) {
            var d = Math.floor(s / 86400);
            var h = Math.floor((s % 86400) / 3600);
            var m = Math.floor((s % 3600) / 60);
            if (d > 0) return "UP " + d + "d " + h + "h";
            if (h > 0) return "UP " + h + "h " + m + "m";
            return "UP " + m + "m";
          }

          function level(pct, warn, crit) {
            if (pct >= crit) return "crit";
            if (pct >= warn) return "warn";
            return "ok";
          }

          function render(data) {
            var sys = data.system;
            document.getElementById("uptime").textContent = fmtUptime(sys.uptime);

            var cpuEl = document.getElementById("m-cpu");
            var cpuText = sys.cpu.percent + "%";
            if (sys.cpu.temp_c !== null && sys.cpu.temp_c !== undefined) {
              cpuText += " · " + sys.cpu.temp_c + "°C";
            }
            cpuEl.textContent = cpuText;
            cpuEl.dataset.level = level(sys.cpu.percent, 80, 95);

            var memEl = document.getElementById("m-mem");
            memEl.textContent =
              fmtBytes(sys.memory.used_bytes) +
              "/" +
              fmtBytes(sys.memory.total_bytes) +
              " (" +
              sys.memory.percent +
              "%)";
            memEl.dataset.level = level(sys.memory.percent, 80, 90);

            var swapEl = document.getElementById("m-swap");
            swapEl.textContent =
              sys.swap.total_bytes > 0
                ? fmtBytes(sys.swap.used_bytes) +
                  "/" +
                  fmtBytes(sys.swap.total_bytes)
                : "N/A";
            swapEl.dataset.level = level(sys.swap.percent, 75, 90);

            document.getElementById("m-load").textContent = sys.load;

            var disksEl = document.getElementById("disks");
            disksEl.replaceChildren();
            data.disks.forEach(function (d) {
              var row = document.createElement("div");
              row.className = "disk";

              var head = document.createElement("div");
              head.className = "disk-head";

              var left = document.createElement("span");
              left.className = "disk-label";
              left.textContent = d.label;
              var mnt = document.createElement("span");
              mnt.className = "disk-mount";
              mnt.textContent = d.mount;
              left.appendChild(mnt);

              var right = document.createElement("span");
              right.className = "disk-info";

              if (!d.mounted) {
                right.textContent = "UNMOUNTED";
                right.dataset.level = "warn";
                head.appendChild(left);
                head.appendChild(right);
                row.appendChild(head);
              } else {
                var lvl = level(d.percent, 85, 90);
                right.textContent =
                  d.percent +
                  "% · " +
                  fmtBytes(d.avail_bytes) +
                  " free / " +
                  fmtBytes(d.total_bytes);
                right.dataset.level = lvl;

                var bar = document.createElement("div");
                bar.className = "bar";
                var fill = document.createElement("div");
                fill.className = "bar-fill";
                fill.style.width = Math.min(100, d.percent) + "%";
                fill.dataset.level = lvl;
                bar.appendChild(fill);

                head.appendChild(left);
                head.appendChild(right);
                row.appendChild(head);
                row.appendChild(bar);
              }
              disksEl.appendChild(row);
            });

            var up = 0;
            var down = 0;
            var off = 0;
            var expected = 0;
            var labels = {
              up: "■ UP",
              starting: "■ INIT",
              off: "□ OFF",
              down: "■ DOWN",
            };

            document.querySelectorAll(".card[data-service]").forEach(function (card) {
              var name = card.dataset.service;
              var info = data.services[name];
              if (!info) return;

              var st = info.status;
              card.dataset.status = st;
              var badge = card.querySelector(".status");
              if (badge) {
                badge.dataset.status = st;
                badge.textContent = labels[st] || st.toUpperCase();
              }

              if (info.autoStart || st === "up" || st === "starting" || st === "down") {
                expected++;
                if (st === "up") up++;
                else if (st === "down") down++;
              } else if (st === "off") {
                off++;
              }
            });

            var sumEl = document.getElementById("summary");
            if (down > 0) {
              sumEl.textContent = up + "/" + expected + " UP · " + down + " DOWN";
              sumEl.dataset.state = "down";
            } else if (up < expected) {
              sumEl.textContent = up + "/" + expected + " UP · STARTING";
              sumEl.dataset.state = "warn";
            } else {
              sumEl.textContent =
                off > 0
                  ? up + "/" + expected + " UP · " + off + " OFF"
                  : up + "/" + expected + " UP";
              sumEl.dataset.state = "ok";
            }
          }

          function refresh() {
            fetch("/status.json?t=" + Date.now(), { cache: "no-store" })
              .then(function (r) {
                if (!r.ok) throw new Error("HTTP " + r.status);
                var hdr = r.headers.get("Date");
                var ms = hdr ? Date.parse(hdr) : NaN;
                var serverNow = Number.isFinite(ms) ? Math.floor(ms / 1000) : null;
                return r.json().then(function (data) {
                  return { data: data, serverNow: serverNow };
                });
              })
              .then(function (res) {
                var data = res.data;
                if (
                  res.serverNow !== null &&
                  typeof data.updated_at === "number" &&
                  res.serverNow - data.updated_at > 60
                ) {
                  var sumEl = document.getElementById("summary");
                  sumEl.textContent = "TELEMETRY STALE";
                  sumEl.dataset.state = "warn";
                  return;
                }
                render(data);
              })
              .catch(function () {
                var sumEl = document.getElementById("summary");
                sumEl.textContent = "TELEMETRY OFFLINE";
                sumEl.dataset.state = "warn";
              });
          }

          refresh();
          setInterval(refresh, 15000);
          document.addEventListener("visibilitychange", function () {
            if (!document.hidden) refresh();
          });
        })();
      </script>
    </body>
    </html>
  '';
in
{
  assertions = lib.concatLists (
    lib.mapAttrsToList (
      name: srv:
      let
        containers = config.virtualisation.oci-containers.containers;
        ports = if containers ? ${name} then containers.${name}.ports else [ ];
        expectedPrefix = "127.0.0.1:${toString srv.port}:";
      in
      lib.optional (ports != [ ]) {
        assertion = lib.any (lib.hasPrefix expectedPrefix) ports;
        message = "Caddy proxy '${name}' expects container 'podman-${name}' to bind ${expectedPrefix}*, got: ${builtins.toJSON ports}";
      }
    ) proxies
  );

  networking.firewall.allowedTCPPorts = [ 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "txg0fk3@proton.me";
    certs.${domain} = {
      extraDomainNames = [ "*.${domain}" ];
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."cloudflare.env".path;
      group = config.services.caddy.group;
    };
  };

  systemd.services.hydra-telemetry = {
    description = "Collect Hydra hardware telemetry and service status";
    wantedBy = [ "multi-user.target" ];
    before = [ "caddy.service" ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "10s";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      RuntimeDirectory = "hydra-dashboard";
      RuntimeDirectoryMode = "0755";
      RuntimeDirectoryPreserve = "yes";
      ExecStart = "${telemetryScript}";
    };
  };

  systemd.timers.hydra-telemetry = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "15s";
      AccuracySec = "1s";
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts =
      (lib.mapAttrs' (
        name: srv:
        lib.nameValuePair "${name}.${domain}" {
          useACMEHost = domain;
          extraConfig = mkReverseProxy srv;
        }
      ) proxies)
      // {
        ${domain} = {
          useACMEHost = domain;
          extraConfig = ''
            handle /status.json {
              root * /run/hydra-dashboard
              header Cache-Control "no-store"
              file_server
            }
            handle {
              root * ${dashboard}
              file_server
            }
          '';
        };
      };
  };
}
