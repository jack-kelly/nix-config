{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Workarounds for nixpkgs' new per-module .cer aggregation (aggregator.nix):
  # v4l2loopback ships its own depmod output, which collides in the buildEnv,
  # and the system76 modules don't ship .ko.cer files, which breaks the merge.
  boot.kernelPackages = pkgs.linuxPackages_latest.extend (
    final: prev: {
      v4l2loopback = prev.v4l2loopback.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          rm -f $out/lib/modules/*/modules.*
        '';
      });
      system76 = prev.system76.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          find $out/lib/modules -name '*.ko' -exec sh -c 'touch "$1.cer"' _ {} \;
        '';
      });
      system76-io = prev.system76-io.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          find $out/lib/modules -name '*.ko' -exec sh -c 'touch "$1.cer"' _ {} \;
        '';
      });
    }
  );

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
  # Lets unpatched, dynamically-linked binaries run (prebuilt dev tools,
  # vendor SDKs, etc.) — general development need, not tied to any one host.
  programs.nix-ld.enable = true;

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
