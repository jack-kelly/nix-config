{ config, lib, ... }:
{
  programs.zellij = {
    enable = true;
    # Hand-rolled below so we can skip autostart over SSH.
    enableZshIntegration = false;
    settings = {
      copy_command = "xclip -selection clipboard";
      show_startup_tips = false;
      scroll_mode_sync = false;
    };
  };

  # Mirrors home-manager's zsh integration (same order, same package; the
  # autostart logic itself comes from `zellij setup`), but not inside SSH sessions: ssh-ing
  # in from another zellij would otherwise nest one (ZELLIJ isn't forwarded).
  programs.zsh.initContent = lib.mkOrder 200 ''
    if [[ "$TERM" != "dumb" && -z "$SSH_CONNECTION" ]]; then
        eval "$(${lib.getExe config.programs.zellij.finalPackage} setup --generate-auto-start zsh)"
    fi
  '';
}
