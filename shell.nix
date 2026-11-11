# Shell for bootstrapping flake-enabled nix and home-manager.
# Flake-only: enter it with 'nix develop' (see devShells in flake.nix).

{ pkgs }:
{
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      just
    ];
  };
}
