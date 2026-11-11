# System side of the work setup (the home side is home/bundles/work).
{ lib, ... }:
{
  services.tailscale.enable = true;

  virtualisation.docker = {
    enable = true;
    # Started on demand through its socket. Hosts that run containers
    # unattended override this.
    enableOnBoot = lib.mkDefault false;
  };
}
