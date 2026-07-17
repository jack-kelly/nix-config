{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal = {
        shell = "${pkgs.zsh}/bin/zsh";
      };

      env = {
        "TERM" = "xterm-256color";
        # exit the shell (and thus close alacritty) when zellij exits
        "ZELLIJ_AUTO_EXIT" = "true";
      };

      window = {
        padding.x = 10;
        padding.y = 10;
        decorations = "buttonless";
      };

      keyboard.bindings = [
        {
          key = "Return";
          mods = "Shift";
          chars = builtins.fromJSON ''"\u001B\r"'';
        }
      ];
    };
  };
}
