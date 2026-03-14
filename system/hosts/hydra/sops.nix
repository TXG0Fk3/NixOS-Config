{ inputs, secrets, ... }:

{
  sops = {
    defaultSopsFile = (secrets + "/common.yaml");
    age = {
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
    };

    secrets = {
      "playit.env" = {
        sopsFile = (secrets + "/hydra.yaml");
        mode = "0400";
        owner = "root";
        group = "root";
      };

      "cloudflared.env" = {
        sopsFile = (secrets + "/hydra.yaml");
        mode = "0400";
        owner = "root";
        group = "root";
      };

      "ts-key" = {
        sopsFile = (secrets + "/hydra.yaml");
        mode = "0400";
        owner = "root";
        group = "root";
      }
    };
  };
}
