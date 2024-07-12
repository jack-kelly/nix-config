{
  pkgs,
  lib,
  ...
}: {
  myNixOS.sddm.enable = lib.mkDefault false;
  myNixOS.xremap-user.enable = lib.mkDefault true;
  myNixOS.virtualisation.enable = lib.mkDefault true;
  myNixOS.stylix.enable = lib.mkDefault true;

  time.timeZone = "Eastern/Detroit";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  fonts.packages = with pkgs; [
    (pkgs.nerdfonts.override {fonts = ["Inconsolata"];})
    cm_unicode
    corefonts
  ];

  # fonts.enableDefaultPackages = true;
  # fonts.fontconfig = {
  #   defaultFonts = {
  #     monospace = ["JetBrainsMono Nerd Font Mono"];
  #     sansSerif = ["JetBrainsMono Nerd Font"];
  #     serif = ["JetBrainsMono Nerd Font"];
  #   };
  # };

  # battery
  services.upower.enable = true;
}
