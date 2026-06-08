{ pkgs, ... }:
{
  imports = [
    ./_1password.nix
  ];

  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
  services.upower.enable = true;

  # Firefox is managed entirely by home-manager (home/bundles/desktop/firefox.nix),
  # which builds the wrapped package (policies, extensions) and installs the
  # 1Password native-messaging host. Do NOT enable the NixOS-level
  # programs.firefox here: it writes /etc/firefox/policies/policies.json, which
  # on Linux OVERRIDES the package's distribution/policies.json — silently
  # shadowing all of home-manager's firefox policies with an empty set.
}
