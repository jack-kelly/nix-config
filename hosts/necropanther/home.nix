{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}: {
  imports = [outputs.homeManagerModules.default];

  myHomeManager = {
    bundles.general.enable = true;
    bundles.desktop.enable = true;
  };

  home = {
    username = "jack";
    homeDirectory = lib.mkDefault "/home/jack";
    stateVersion = "24.05";
  };
}