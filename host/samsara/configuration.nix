{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # System76 Open Firmware + common PC hardware. There is no thelio-major
    # profile in nixos-hardware (closest named one is thelio-mega); the Major is
    # an AMD Threadripper + nvidia desktop, so we compose the same building blocks
    # the mega profile uses.
    inputs.nixos-hardware.nixosModules.system76
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    # Single dGPU driving the display directly — the non-prime variant, unlike
    # lobotomizer's laptop hybrid graphics. Threadripper has no iGPU.
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    ../bundles/global
    ../bundles/i3
    ./hardware-configuration.nix
  ];
  networking.hostName = "samsara";

  # Compute tower: the desktop is available but NOT started at boot. The i3
  # bundle enables the `ly` login manager by default; force it off and provide
  # `startx` instead. Log in on the TTY and run `startx` to bring up i3.
  # The nvidia driver still drives an attached monitor on the console for
  # install/recovery regardless of whether X is running.
  services.displayManager.ly.enable = lib.mkForce false;
  services.xserver.displayManager.startx = {
    enable = true;
    generateScript = true; # /etc/X11/xinit/xinitrc launches the i3 session
  };

  # NVIDIA A400 (Ada Lovelace, AD107). Open kernel module is recommended on
  # Turing and newer.
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };

  # Local compute tooling (matches lobotomizer). No `nvidia-offload` wrapper —
  # there's a single GPU, so CUDA apps use it directly with no PRIME offload.
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
  ];

  programs.nix-ld.enable = true;

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;
  # Persistent tower — keep containers/daemon across boots.
  virtualisation.docker.enableOnBoot = true;

  system.stateVersion = "25.11";
}
