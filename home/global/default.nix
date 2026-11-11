{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../bundles/cli
  ];

  systemd.user.startServices = "sd-switch";

  # useGlobalPkgs makes home-manager ignore its own nixpkgs, so stylix's
  # package-recoloring overlays (nixos-icons, gtksourceview) are no-ops here.
  # Left enabled (the default) they still register overlay functions on every
  # profile — even ones with stylix disabled — tripping the useGlobalPkgs
  # "nixpkgs.overlays set" warning. Disable them everywhere.
  stylix.overlays.enable = false;

  programs = {
    git.enable = true;
  };

  home = {
    stateVersion = lib.mkDefault "26.05";
    shell.enableZshIntegration = true;
  };

  xdg.enable = true;
}
