{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--color 16" ];
    # Yield Ctrl-R to atuin (see atuin.nix); keep fzf's Ctrl-T / Alt-C widgets.
    historyWidget.command = "";
  };
}
