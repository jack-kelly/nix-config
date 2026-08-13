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

      saleae-logic
    ])
    ++ [
      (pkgs.callPackage ../../../pkgs/claude-code { })
    ]
    ++ (with pkgs-stable; [
      # unstable's avro-c++ is built against fmt 12, which breaks libserdes' build
      kcat

      slack
    ]);
}
