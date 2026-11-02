{ pkgs, pkgs-stable, ... }:
{
  imports = [
    ./pi.nix
  ];

  home.packages =
    (with pkgs; [
      awscli2
      openvpn
      networkmanager-openvpn
      uv
    ])
    ++ [
      (pkgs.callPackage ../../../pkgs/claude-code { })
    ]
    ++ (with pkgs-stable; [
      # unstable's avro-c++ is built against fmt 12, which breaks libserdes' build
      kcat

      slack

      # unstable's saleae-logic depends on gtk2, which is marked broken
      saleae-logic
    ]);
}
