{ inputs, pkgs, ... }:
{
  programs._1password = {
    enable = true;
  };
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "jack" ];
    # Unstable's 8.12.42 ships a chrome_crashpad_handler that nixpkgs doesn't
    # patchelf, so it dies on launch with "libglib-2.0.so.0: cannot open shared
    # object file". Stable's 8.12.21 works. Drop once unstable patches it.
    package =
      (import inputs.nixpkgs-stable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      })._1password-gui;
  };
}
