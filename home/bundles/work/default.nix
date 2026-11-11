{ pkgs, pkgs-stable, ... }:
{
  imports = [
    ./pi.nix
  ];

  home.packages =
    (with pkgs; [
      awscli2
      claude-code # ours, via the flake overlay (see pkgs/)
      openvpn
      networkmanager-openvpn
      slack
      uv
    ])
    ++ (with pkgs-stable; [
      # unstable's avro-c++ is built against fmt 12, which breaks libserdes' build
      kcat

      # unstable's saleae-logic depends on gtk2, which is marked broken
      saleae-logic
    ]);

  # This sets an i3 bundle option, so the work bundle needs the i3 bundle
  # alongside it.
  local.i3.startupApps = [ "${pkgs.slack}/bin/slack" ];
}
