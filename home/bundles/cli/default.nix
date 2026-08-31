{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./atuin.nix
    ./bat.nix
    ./broot.nix
    ./claude.nix
    ./direnv.nix
    ./eza.nix
    ./fzf.nix
    ./go.nix
    ./gh.nix
    ./git.nix
    ./helix.nix
    ./jujutsu.nix
    ./ssh.nix
    ./starship.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  home.packages =
    (with pkgs; [
      bottom
      difftastic
      dig
      dnsmasq
      eza
      fd
      fzf
      gcc
      gnumake
      gnupg
      htop
      ijq
      arp-scan
      bandwhich
      hping
      fping
      iperf3
      just
      jq
      killall
      lazygit
      lnav
      ngrep
      nmap
      p7zip
      tio
      pciutils
      psmisc
      python3
      ripgrep
      socat
      tcpdump
      tree
      trippy
      unzip
      usbutils
      whois
      wireshark-cli
      xclip
      xh
      xz
      yazi
      nil
      nixfmt-tree
      nh
    ])
    ++ [
      # Upstream's flake bumped go.mod/go.sum without regenerating vendorHash,
      # so its own value is stale. Override it until they fix it upstream.
      (inputs.tailcat.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (_: {
        vendorHash = "sha256-EqmXVZsyuRjR4R+6V8E5pQtlAI88oskDaghfdv96sc0=";
      }))
    ];
}
