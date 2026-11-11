# Base for every graphical host, whatever sits on top: the i3 bundle imports
# this, and giza-power-plant adds GNOME in its own config.
{ pkgs, ... }:
{
  imports = [
    ./1password.nix
  ];

  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Only affects machines that have a touchpad.
  services.libinput.touchpad.disableWhileTyping = true;

  services.printing.enable = true;

  # AppImages need FUSE plus an FHS sandbox; binfmt lets them be exec'd directly
  # instead of via `appimage-run`.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

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

  # GUI for ZSA keyboards; the udev rules and wally-cli are in the global bundle.
  environment.systemPackages = [ pkgs.keymapp ];

  # Firefox is managed entirely by home-manager (home/bundles/desktop/firefox.nix),
  # which builds the wrapped package (policies, extensions) and installs the
  # 1Password native-messaging host. Do NOT enable the NixOS-level
  # programs.firefox here: it writes /etc/firefox/policies/policies.json, which
  # on Linux OVERRIDES the package's distribution/policies.json — silently
  # shadowing all of home-manager's firefox policies with an empty set.
}
