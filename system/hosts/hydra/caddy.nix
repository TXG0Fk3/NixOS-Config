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
      target = "127.0.0.1:8096";
    };
    radarr = {
      title = "Radarr";
      category = "Media";
      target = "127.0.0.1:7878";
    };
    sonarr = {
      title = "Sonarr";
      category = "Media";
      target = "127.0.0.1:8989";
    };
    prowlarr = {
      title = "Prowlarr";
      category = "Media";
      target = "127.0.0.1:9696";
    };
    qbittorrent = {
      title = "qBittorrent";
      category = "Downloads";
      target = "127.0.0.1:8080";
    };
    forgejo = {
      title = "Forgejo";
      category = "Development";
      target = "127.0.0.1:3000";
    };
    syncthing = {
      title = "Syncthing";
      category = "Storage";
      target = ''
        127.0.0.1:8384 {
          header_up Host localhost
        }
      '';
    };
    filebrowser = {
      title = "FileBrowser";
      category = "Storage";
      target = "127.0.0.1:8090";
    };
    crafty = {
      title = "Crafty";
      category = "Gaming";
      target = ''
        https://127.0.0.1:8443 {
          transport http {
            tls_insecure_skip_verify
          }
        }
      '';
    };
  };

  cards = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: srv: ''
      <a class="card" href="https://${name}.${domain}">
        <span class="category">${srv.category}</span>
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
      <title>HYDRA</title>
      <style>
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
        }
        header {
          display: flex;
          justify-content: space-between;
          align-items: baseline;
          border-bottom: 1px solid ${c.fg};
          padding-bottom: 10px;
          margin-bottom: 16px;
        }
        h1 {
          font-size: 18px;
          font-weight: bold;
          letter-spacing: 2px;
        }
        .domain {
          color: ${c.accent};
          font-size: 12px;
        }
        .grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
          gap: 12px;
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
        .card .category {
          font-size: 10px;
          color: ${c.accent};
          text-transform: uppercase;
          letter-spacing: 1px;
        }
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
          outline: none;
        }
        .card:hover .category,
        .card:hover .host,
        .card:focus-visible .category,
        .card:focus-visible .host {
          color: ${c.bg};
        }
      </style>
    </head>
    <body>
      <main>
        <header>
          <h1>HYDRA</h1>
          <span class="domain">${domain}</span>
        </header>
        <div class="grid">
          ${cards}
        </div>
      </main>
    </body>
    </html>
  '';
in
{
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

  services.caddy = {
    enable = true;
    virtualHosts =
      (lib.mapAttrs' (
        name: srv:
        lib.nameValuePair "${name}.${domain}" {
          useACMEHost = domain;
          extraConfig = ''
            reverse_proxy ${srv.target}
          '';
        }
      ) proxies)
      // {
        ${domain} = {
          useACMEHost = domain;
          extraConfig = ''
            root * ${dashboard}
            file_server
          '';
        };
      };
  };
}
