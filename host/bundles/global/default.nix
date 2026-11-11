{ inputs, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    # This flake's own packages (pkgs/), e.g. claude-code. Replaces the
    # nixpkgs package of the same name.
    inputs.self.overlays.default

    # electron 43 leaves obsidian as a blank window (webFrame init fails in the
    # renderer); 44 works. Drop once the default electron fixes it.
    (final: prev: {
      obsidian = prev.obsidian.override { electron = final.electron_44; };
    })
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "America/Detroit";

  i18n.defaultLocale = "en_US.UTF-8";

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
  # Lets unpatched, dynamically-linked binaries run (prebuilt dev tools,
  # vendor SDKs, etc.) — general development need, not tied to any one host.
  programs.nix-ld.enable = true;

  services.openssh.enable = true;
  services.envfs.enable = true;

  # ZSA keyboards get plugged into any of these machines: udev rules for
  # flashing, plus the CLI flasher. The GUI (keymapp) is in the desktop bundle.
  hardware.keyboard.zsa.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wally-cli
    wget
  ];
}
