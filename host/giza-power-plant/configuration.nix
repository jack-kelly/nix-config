{ config, pkgs, ... }:
{
  imports = [
    ../bundles/global
    ../bundles/desktop
    ./hardware-configuration.nix
  ];
  networking.hostName = "giza-power-plant";

  services.xserver.videoDrivers = [
    "nvidia"
    "modesetting"
  ];

  hardware = {
    graphics.enable = true;

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  programs = {
    steam.enable = true;
    noisetorch.enable = true;
    appimage = {
      binfmt = true;
      enable = true;
    };
  };

  # Workaround for noisetorch on pipewire >= 1.6.3: pipewire's filter-graph
  # LADSPA loader now rejects absolute paths outside $LADSPA_PATH, but
  # noisetorch dumps librnnoise to /tmp. See noisetorch/NoiseTorch#467.
  systemd.user.services.pipewire-pulse.environment.LADSPA_PATH = "/tmp";

  system.stateVersion = "25.05";
}
