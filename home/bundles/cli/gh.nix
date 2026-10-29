{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      gh-markdown-preview
      gh-stack
    ];
    settings = {
      version = "1";
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
