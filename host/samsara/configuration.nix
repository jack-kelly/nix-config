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
    ../bundles/ups
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
      # patchelf 0.19.2 (unstable) corrupts nvidia-smi's program headers (segfault in ld.so
      # on launch); build the userspace driver with the 25.05 patchelf (0.15.2) instead.
      package = config.boot.kernelPackages.nvidiaPackages.latest.overrideAttrs (old: {
        nativeBuildInputs = [
          inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.patchelf
        ]
        ++ (old.nativeBuildInputs or [ ]);
      });
    };

    # udev rules for the G700s receiver; solaar itself comes in via home
    logitech.wireless.enable = true;
  };

  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
  ];

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  # Running lots of containers exhausts the default ARP/neighbor table
  # thresholds, causing "neighbour table overflow" and dropped connectivity.
  boot.kernel.sysctl = {
    "net.ipv4.neigh.default.gc_thresh1" = 4096;
    "net.ipv4.neigh.default.gc_thresh2" = 8192;
    "net.ipv4.neigh.default.gc_thresh3" = 16384;
  };

  system.stateVersion = "25.11";
}
