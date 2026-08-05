{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.system76
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    ../bundles/global
    ../bundles/i3
    ../bundles/webcam
    ./hardware-configuration.nix
  ];
  networking.hostName = "samsara";

  # NVIDIA A400 (Ada Lovelace), open kernel module.
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    # udev rules for the G700s receiver; solaar itself comes in via home
    logitech.wireless.enable = true;
  };

  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
  ];

  programs.nix-ld.enable = true;

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  system.stateVersion = "25.11";
}
