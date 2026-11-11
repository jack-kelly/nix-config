# Shell for bootstrapping: everything the justfile recipes call, for a
# machine that hasn't switched to this config yet.
# Flake-only: enter it with 'nix develop' (see devShells in flake.nix).

{ pkgs }:
{
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix
      git
      just
      nh
      nixfmt-tree
    ];
  };
}
