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

  telemetryScript = pkgs.writers.writePython3 "hydra-telemetry" { } (
    builtins.readFile ./dashboard/telemetry.py
  );

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

  themeCss = pkgs.writeText "theme.css" ''
    :root {
      --bg: ${c.bg};
      --fg: ${c.fg};
      --dim: ${c.dim};
      --mid: ${c.mid};
      --accent: ${c.accent};
      --green: ${c.green};
      --orange: ${c.orange};
      --red: ${c.red};
      --layer1: ${c.layer1};
      --layer3: ${c.layer3};
    }
  '';

  indexHtml = pkgs.writeText "index.html" (
    builtins.replaceStrings [ "@DOMAIN@" "@CARDS@" ] [ domain cards ] (
      builtins.readFile ./dashboard/index.html
    )
  );

  dashboard = pkgs.linkFarm "hydra-dashboard" [
    {
      name = "index.html";
      path = indexHtml;
    }
    {
      name = "theme.css";
      path = themeCss;
    }
    {
      name = "style.css";
      path = ./dashboard/style.css;
    }
    {
      name = "app.js";
      path = ./dashboard/app.js;
    }
  ];
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
      ExecStart = "${telemetryScript} ${telemetryConfig}";
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
