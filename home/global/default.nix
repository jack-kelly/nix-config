{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../bundles/cli
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  targets.genericLinux.enable = true;

  systemd.user.startServices = "sd-switch";

  # useGlobalPkgs makes home-manager ignore its own nixpkgs, so stylix's
  # package-recoloring overlays (nixos-icons, gtksourceview) are no-ops here.
  # Left enabled (the default) they still register overlay functions on every
  # profile — even ones with stylix disabled — tripping the useGlobalPkgs
  # "nixpkgs.overlays set" warning. Disable them everywhere.
  stylix.overlays.enable = false;

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "jack";
    homeDirectory = lib.mkDefault "/home/jack";
    stateVersion = lib.mkDefault "26.05";
    shell.enableZshIntegration = true;
  };

  xdg.enable = true;
}
