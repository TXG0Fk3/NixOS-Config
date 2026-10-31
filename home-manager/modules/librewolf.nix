{
  pkgs,
  colors,
  ...
}:

let
  c = colors;

  addon = slug: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "force_installed";
    private_browsing = true;
  };
in
{
  programs.librewolf = {
    enable = true;

    # Policies & Extensions
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;

      # The system resolver already uses DNS over TLS
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = addon "ublock-origin";
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = addon "vimium-ff";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = addon "bitwarden-password-manager";
        "addon@darkreader.org" = addon "darkreader";
        "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = addon "violentmonkey";
        "{74145f27-f039-47ce-a470-a662b129930a}" = addon "clearurls";
        "leechblockng@proginosko.com" = addon "leechblock-ng";
        "{e58d3966-3d76-4cd9-8552-1582fbc800c1}" = addon "buster-captcha-solver";
        "myallychou@gmail.com" = addon "youtube-recommended-videos";
        "{6c00218c-707a-4977-84cf-36df1cef310f}" = addon "port-authority";
        "vpn@proton.ch" = addon "proton-vpn-firefox-extension";
        "{154cddeb-4c8b-4627-a478-c7e5b427ffdf}" = addon "popupoff";
      };
    };

    # Overrides
    # Overrides
    settings = {
      # Custom stylesheets & fonts
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "font.name.monospace.x-western" = "JetBrainsMono Nerd Font";

      # Fingerprinting & Dark mode fix
      "privacy.resistFingerprinting" = false;
      "privacy.resistFingerprinting.letterboxing" = false;
      "privacy.fingerprintingProtection" = true;
      "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme,-JSDateTimeUTC";

      "layout.css.prefers-color-scheme.content-override" = 0;
      "ui.systemUsesDarkTheme" = 1;
      "browser.theme.content-theme" = 0;
      "browser.theme.toolbar-theme" = 0;
      "browser.in-content.dark-mode" = true;

      # Session & Privacy
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.sessions" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;
      "network.cookie.lifetimePolicy" = 0;
      "browser.sessionstore.resume_from_crash" = true;
      "browser.startup.page" = 3;

      # Tracking & Network
      "browser.contentblocking.category" = "strict";
      "privacy.globalprivacycontrol.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "dom.security.https_only_mode" = true;
      "security.OCSP.require" = false;
      "network.http.referer.XOriginPolicy" = 1;
      "network.http.referer.XOriginTrimmingPolicy" = 2;
      "network.prefetch-next" = false;
      "network.dns.disablePrefetch" = true;
      "network.predictor.enabled" = false;

      # Hardware & Wayland
      "webgl.disabled" = false;
      "librewolf.webgl.prompt" = false;
      "gfx.webrender.all" = true;
      "media.ffmpeg.vaapi.enabled" = true;
      "widget.dmabuf.force-enabled" = true;

      # UI & Input
      "browser.tabs.inTitlebar" = 1;
      "browser.compactmode.show" = true;
      "browser.uidensity" = 1;
      "general.autoScroll" = true;
      "middlemouse.paste" = false;
      "apz.gtk.kinetic_scroll.enabled" = false;

      # Disable bloat & suggestions
      "browser.ml.enable" = false;
      "browser.ml.chat.enabled" = false;
      "browser.tabs.firefox-view" = false;
      "browser.search.suggest.enabled" = false;
      "browser.urlbar.suggest.quicksuggest.sponsored" = false;
      "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = true;
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    };
    # Default Profile
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      # Search Engines
      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";

        order = [
          "ddg"
          "Nix Packages"
          "NixOS Options"
          "Home Manager"
          "GitHub"
        ];

        engines = {
          "bing".metaData.hidden = true;
          "ebay".metaData.hidden = true;
          "wikipedia".metaData.alias = "@w";
          "ddg".metaData.alias = "@d";

          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "NixOS Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "options";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "Home Manager" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                  {
                    name = "release";
                    value = "master";
                  }
                ];
              }
            ];
            definedAliases = [ "@hm" ];
          };

          "GitHub" = {
            urls = [ { template = "https://github.com/search?q={searchTerms}&type=code"; } ];
            definedAliases = [ "@gh" ];
          };
        };
      };

      # UI Theme
      userChrome = ''
        /* base */
        *,
        *::before,
        *::after {
          border-radius: 0px !important;
          box-shadow: none !important;
        }

        :root {
          --toolbar-bgcolor: ${c.bg} !important;
          --toolbar-color: ${c.fg} !important;
          --lwt-accent-color: ${c.bg} !important;
          --lwt-text-color: ${c.fg} !important;

          --toolbar-field-background-color: ${c.bg} !important;
          --toolbar-field-color: ${c.fg} !important;
          --toolbar-field-border-color: ${c.fg} !important;
          --toolbar-field-focus-background-color: ${c.bg} !important;
          --toolbar-field-focus-color: ${c.fg} !important;
          --toolbar-field-focus-border-color: ${c.accent} !important;

          --arrowpanel-background: ${c.bg} !important;
          --arrowpanel-color: ${c.fg} !important;
          --arrowpanel-border-color: ${c.fg} !important;

          --tab-block-margin: 0px !important;
          --tab-min-height: 32px !important;
          --UIDensity-compact-tab-min-height: 32px !important;
        }

        /* toolbars */
        #navigator-toolbox,
        #TabsToolbar,
        #nav-bar,
        #PersonalToolbar,
        #sidebar-box,
        #sidebar-header {
          background-color: ${c.bg} !important;
          color: ${c.fg} !important;
          border: none !important;
        }

        #navigator-toolbox {
          border-bottom: 1px solid ${c.fg} !important;
        }

        #nav-bar {
          border-top: 1px solid ${c.fg} !important;
          padding: 2px 4px !important;
        }

        /* tabs */
        .tabbrowser-tab {
          padding: 0 2px !important;
        }

        .tab-background {
          background-color: ${c.bg} !important;
          border: 1px solid ${c.dim} !important;
          margin: 2px 0 !important;
        }

        .tabbrowser-tab:hover:not([visuallyselected]) .tab-background {
          border-color: ${c.fg} !important;
        }

        .tabbrowser-tab[visuallyselected] .tab-background {
          background-color: ${c.fg} !important;
          border: 1px solid ${c.fg} !important;
        }

        .tabbrowser-tab[visuallyselected] .tab-label,
        .tabbrowser-tab[visuallyselected] .tab-close-button,
        .tabbrowser-tab[visuallyselected] .tab-icon-image {
          color: ${c.bg} !important;
          fill: ${c.bg} !important;
          font-weight: bold !important;
        }

        .tabbrowser-tab[visuallyselected] .tab-audio-button,
        .tabbrowser-tab[visuallyselected] .tab-icon-overlay {
          --my-fill: ${c.bg} !important;
          fill: ${c.bg} !important;
          color: ${c.bg} !important;
        }

        .tabbrowser-tab[visuallyselected] .tab-audio-button:hover,
        .tabbrowser-tab[visuallyselected] .tab-icon-overlay:hover {
          --my-fill: ${c.bg} !important;
          fill: ${c.bg} !important;
        }

        .tabbrowser-tab:not([visuallyselected]) .tab-label {
          color: ${c.mid} !important;
        }

        .tabbrowser-tab::after,
        .tabbrowser-tab::before {
          display: none !important;
        }      

        /* urlbar */
        #urlbar-background {
          background-color: ${c.bg} !important;
          border: 1px solid ${c.fg} !important;
          border-radius: 0px !important;
          box-shadow: none !important;
        }

        #urlbar[focused] > .urlbar-background,
        #urlbar[open] > .urlbar-background {
          background-color: ${c.bg} !important;
          border: 1px solid ${c.accent} !important;
          outline: none !important;
          box-shadow: none !important;
        }

        #urlbar {
          --toolbar-field-background-color: ${c.bg} !important;
          --toolbar-field-color: ${c.fg} !important;
          --toolbar-field-border-color: ${c.fg} !important;

          --toolbar-field-focus-background-color: ${c.bg} !important;
          --toolbar-field-focus-color: ${c.fg} !important;
          --toolbar-field-focus-border-color: ${c.accent} !important;
        }

        /* Search results */
        .urlbarView {
          background-color: ${c.bg} !important;
          border: 1px solid ${c.accent} !important;
          border-top: none !important;
          margin-inline: 0 !important;
          width: 100% !important;
          border-radius: 0px !important;
          box-shadow: none !important;
          padding: 0 !important;
        }

        .urlbarView-body-inner,
        .urlbarView-results {
          background-color: ${c.bg} !important;
          padding-block: 2px !important;
        }

        .urlbarView-row {
          min-height: 28px !important;
          padding-block: 2px !important;
          margin-block: 0 !important;
        }

        .urlbarView-row-inner {
          padding-block: 2px !important;
          min-height: 24px !important;
        }

        .urlbarView-row[selected],
        .urlbarView-row[aria-selected="true"],
        .urlbarView-row:hover {
          background-color: ${c.fg} !important;
          color: ${c.bg} !important;
        }

        .urlbarView-row[selected] .urlbarView-url,
        .urlbarView-row[selected] .urlbarView-title,
        .urlbarView-row[selected] .urlbarView-action,
        .urlbarView-row[aria-selected="true"] .urlbarView-url,
        .urlbarView-row[aria-selected="true"] .urlbarView-title,
        .urlbarView-row[aria-selected="true"] .urlbarView-action,
        .urlbarView-row:hover .urlbarView-url,
        .urlbarView-row:hover .urlbarView-title,
        .urlbarView-row:hover .urlbarView-action {
          color: ${c.bg} !important;
        }

        .urlbarView-results {
          padding-bottom: 2px !important;
        }

        /* buttons */
        toolbar .toolbarbutton-1:hover > .toolbarbutton-icon,
        toolbar .toolbarbutton-1:hover > .toolbarbutton-text,
        toolbar .toolbarbutton-1:hover > .toolbarbutton-badge-stack {
          background-color: ${c.fg} !important;
          color: ${c.bg} !important;
          fill: ${c.bg} !important;
        }

        /* menus & popups */
        menupopup,
        panel {
          --panel-background-color: ${c.bg} !important;
          --panel-text-color: ${c.fg} !important;
          --panel-border-color: ${c.fg} !important;
          --panel-border-radius: 0px !important;

          /* fallback for older versions */
          --panel-background: ${c.bg} !important;
          --panel-color: ${c.fg} !important;
        }

        menupopup::part(content),
        panel::part(content) {
          background-color: ${c.bg} !important;
          color: ${c.fg} !important;
          border-color: ${c.fg} !important;
          border-radius: 0px !important;
        }

        menuitem:hover,
        menu:hover,
        menuitem[_moz-menuactive="true"],
        menu[_moz-menuactive="true"] {
          background-color: ${c.fg} !important;
          color: ${c.bg} !important;
        }        

        menuseparator {
          border-color: ${c.dim} !important;
        }

        /* window controls */
        .titlebar-buttonbox-container {
          display: none !important;
        }

        /* find bar */
        findbar {
          appearance: none !important;
          background-image: none !important;
          background-color: ${c.bg} !important;
          color: ${c.fg} !important;
          border-top: 1px solid ${c.fg} !important;
        }

        .findbar-container {
          background-color: transparent !important;
        }

        findbar .findbar-textbox {
          appearance: none !important;
          background-color: ${c.bg} !important;
          color: ${c.fg} !important;
          border: 1px solid ${c.fg} !important;
          border-radius: 0px !important;
          box-shadow: none !important;
        }

        findbar .findbar-textbox:focus {
          border-color: ${c.accent} !important;
        }

        findbar toolbarbutton {
          appearance: none !important;
          background-color: transparent !important;
          fill: ${c.fg} !important;
          color: ${c.fg} !important;
        }

        findbar toolbarbutton:hover {
          background-color: ${c.fg} !important;
          fill: ${c.bg} !important;
          color: ${c.bg} !important;
        }
      '';

      # Internal Pages Theme
      userContent = ''
        /* New Tab + Home */
        @-moz-document url("about:newtab"),
                       url("about:home"),
                       url-prefix("about:newtab"),
                       url-prefix("about:home") {

          body {
            background-color: ${c.bg} !important;
            color: ${c.fg} !important;
          }

          /* search bar */
          .search-wrapper .search-handoff-button,
          .search-wrapper input,
          #newtab-search-text,
          .search-handoff-button {
            background-color: ${c.bg} !important;
            color: ${c.fg} !important;
            border: 1px solid ${c.fg} !important;
            border-radius: 0 !important;
            box-shadow: none !important;
            outline: none !important;
          }

          .search-wrapper .search-handoff-button:hover,
          .search-wrapper input:hover,
          #newtab-search-text:hover,
          .search-handoff-button:hover,
          .search-wrapper .search-handoff-button:focus,
          .search-wrapper input:focus,
          #newtab-search-text:focus,
          .search-handoff-button:focus {
            border-color: ${c.accent} !important;
            box-shadow: none !important;
          }

          /* shortcuts */
          .top-site-outer .tile {
            background-color: ${c.bg} !important;
            border: 1px solid ${c.fg} !important;
            border-radius: 0 !important;
            box-shadow: none !important;
            outline: none !important;
          }

          .top-site-outer .tile .icon-wrapper,
          .top-site-outer .tile .top-site-icon,
          .top-site-outer .default-icon {
            border: none !important;
            outline: none !important;
            box-shadow: none !important;
            background-color: transparent !important;
          }

          .top-site-outer:hover .tile,
          .top-site-outer:focus-within .tile {
            border-color: ${c.fg} !important;
            background-color: ${c.bg} !important;
          }

          .top-site-outer .title .title-label {
            color: ${c.fg} !important;
            text-shadow: none !important;
          }

          /* shortcuts context menu button */
          .top-site-outer .context-menu-button,
          .context-menu-button {
            background-color: transparent !important;
            background-image: none !important;
            border: none !important;
            border-radius: 0 !important;
            box-shadow: none !important;
            outline: none !important;
            fill: ${c.fg} !important;
            color: ${c.fg} !important;
          }

          .top-site-outer .context-menu-button:hover,
          .context-menu-button:hover {
            background-color: ${c.fg} !important;
            color: ${c.bg} !important;
            fill: ${c.bg} !important;
            border: none !important;
          }

          /* add shortcut button */
          .top-site-outer .tile.add-button,
          .top-site-button.add-button,
          .add-button,
          .top-site-outer .add-button {
            background-color: ${c.bg} !important;
            background-image: none !important;
            border: 1px solid ${c.fg} !important;
            border-radius: 0 !important;
            color: ${c.fg} !important;
            fill: ${c.fg} !important;
            box-shadow: none !important;
            outline: none !important;
          }

          .top-site-outer .tile.add-button:hover,
          .add-button:hover {
            background-color: ${c.fg} !important;
            color: ${c.bg} !important;
            fill: ${c.bg} !important;
          }

          /* customize button */
          .personalize-button,
          .open-customization-button,
          .customize-menu-button,
          .button-background {
            background-color: ${c.bg} !important;
            background-image: none !important;
            border: 1px solid ${c.fg} !important;
            border-radius: 0 !important;
            color: ${c.fg} !important;
            fill: ${c.fg} !important;
            box-shadow: none !important;
            outline: none !important;
          }

          .personalize-button:hover,
          .open-customization-button:hover,
          .button-background:hover {
            background-color: ${c.fg} !important;
            color: ${c.bg} !important;
            fill: ${c.bg} !important;
          }
        }

        /* internal about pages */
        @-moz-document url("about:blank") {
          body {
            background-color: ${c.bg} !important;
            color: ${c.fg} !important;
          }
        }

        @-moz-document url-prefix("about:") {
          * {
            border-radius: 0px !important;
          }
          :root {
            --in-content-page-background: ${c.bg} !important;
            --in-content-page-color: ${c.fg} !important;
            --in-content-box-background: ${c.bg} !important;
            --in-content-box-border-color: ${c.fg} !important;
            --in-content-primary-button-background: ${c.accent} !important;
            --in-content-primary-button-text-color: ${c.bg} !important;
            --in-content-primary-button-background-hover: ${c.fg} !important;
          }
        }
      '';
    };
  };
}
