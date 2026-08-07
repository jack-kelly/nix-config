{ pkgs, ... }:
{
  home.packages =
    (with pkgs; [
      awscli2
      kcat
      openvpn
      networkmanager-openvpn
      uv

      saleae-logic
      gemini-cli
      pi-coding-agent
    ])
    ++ [
      (pkgs.callPackage ../../../pkgs/claude-code { })
    ]
    ++ (with pkgs; [
      slack
    ]);
}
