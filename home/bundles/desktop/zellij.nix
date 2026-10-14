{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      copy_command = "xclip -selection clipboard";
      show_startup_tips = false;
      scroll_mode_sync = false;
    };
  };
}
