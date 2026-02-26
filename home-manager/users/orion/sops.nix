{
  inputs,
  secrets,
  config,
  ...
}:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = (secrets + "/common.yaml");
    age.keyFile = "/home/TXG0Fk3/.config/sops/age/keys.txt";

    secrets = {
      "git/userName" = { };
      "git/userEmail" = { };
    };

    templates."git-secrets" = {
      content = ''
        [user]
          name = ${config.sops.placeholder."git/userName"}
          email = ${config.sops.placeholder."git/userEmail"}
      '';
    };
  };
}
