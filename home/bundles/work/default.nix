{ pkgs, ... }:
{
  home.packages =
    (with pkgs; [
      awscli2
      openvpn
      networkmanager-openvpn
      uv

      saleae-logic
      gemini-cli
    ])
    ++ [
      (pkgs.callPackage ../../../pkgs/claude-code { })
    ]
    ++ (with pkgs; [
      slack
    ]);
}
