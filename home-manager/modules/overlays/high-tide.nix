self: super: {
  high-tide = super.high-tide.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "Nokse22";
      repo = "high-tide";
      rev = "f86a0c0b124226341e24b46c0cc175c853e61b08";
      sha256 = "03ppjclsp6mka3189yb0f412132f4zzvnkdc48fh30442pdpfng4";
    };
    version = "git-f86a0c0";
  });
}