{
  rustPlatform,
  fetchFromGitLab,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dmemcg-booster";
  version = "0.1.3";

  src = fetchFromGitLab {
    domain = "gitlab.steamos.cloud";
    owner = "holo";
    repo = "dmemcg-booster";
    tag = finalAttrs.version;
    hash = "sha256-JDT+JKxgaETinIHiP0Pqb7fPNrvcI6AQu90nmoA/YuI=";
  };

  postPatch = ''
    substituteInPlace *.service \
      --replace-fail /usr/bin/dmemcg-booster $out/bin/dmemcg-booster
  '';

  cargoHash = "sha256-NHK4734Jvi4RJieGn0RjYU0PzQFqaE4exHG77dmukig=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  postInstall = ''
    install -Dm644 dmemcg-booster-system.service "$out/lib/systemd/system/dmemcg-booster-system.service"
    install -Dm644 dmemcg-booster-user.service "$out/lib/systemd/user/dmemcg-booster-user.service"
  '';
})
