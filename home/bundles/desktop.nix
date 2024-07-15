{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: {
  options = {
    myHomeManager.startupScript = lib.mkOption {
      default = "";
      description = ''
        Startup script
      '';
    };
  };

  config = {

    myHomeManager = {
      hyprland.enable   = lib.mkDefault true;
      zathura.enable    = lib.mkDefault true;
      rofi.enable       = lib.mkDefault true;
      alacritty.enable  = lib.mkDefault true;
      kitty.enable      = lib.mkDefault true;
      chromium.enable   = lib.mkDefault true;
      gimp.enable       = lib.mkDefault true;
      vesktop.enable    = lib.mkDefault true;
      rbw.enable        = lib.mkDefault true;
      xremap.enable     = lib.mkDefault true;
      firefox.enable    = lib.mkDefault true;
      gtk.enable        = lib.mkDefault true;
      zellij.enable     = lib.mkDefault true;
      _1password.enable = lib.mkDefault true;
    };

    qt.enable = true;
    qt.platformTheme = "gtk";
    qt.style.name = "adwaita-dark";

    home.sessionVariables = {
      QT_STYLE_OVERRIDE = "adwaita-dark";
    };

    services.udiskie.enable = true;
    services.printing.enable = true;

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    xdg.mimeApps.defaultApplications = {
      "text/plain" = ["neovide.desktop"];
      "application/pdf" = ["zathura.desktop"];
      "image/*" = ["imv.desktop"];
      "video/png" = ["mpv.desktop"];
      "video/jpg" = ["mpv.desktop"];
      "video/*" = ["mpv.desktop"];
    };

    services.mako = {
      enable = true;
      borderRadius = 5;
      borderSize = 2;
      defaultTimeout = 10000;
      layer = "overlay";
    };

    home.packages = with pkgs; [
      feh
      noisetorch
      polkit
      polkit_gnome
      lxsession
      pulsemixer
      pavucontrol
      adwaita-qt
      pcmanfm
      libnotify

      pywal
      neovide
      ripdrag
      mpv
      sxiv
      zathura

      lm_sensors
      upower

      cm_unicode

      virt-manager

      wezterm
      kitty

      easyeffects
      gegl
    ];
  };
}
