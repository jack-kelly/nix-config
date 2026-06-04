{ pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  # Exposes `pkgs.firefox-addons.*` (built through our unfree-allowing pkgs).
  nixpkgs.overlays = [ inputs.firefox-addons.overlays.default ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "America/Detroit";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  users.users.jack = {
    isNormalUser = true;
    description = "Jack Kelly";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "video"
      "render"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFKamE24xWtnPe29Q7GpmqwO7LA0U68qk3TS9d49DMaP"
    ];
  };

  programs.zsh.enable = true;

  services.openssh.enable = true;
  services.envfs.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];
  environment.shells = with pkgs; [
    zsh
  ];
}
