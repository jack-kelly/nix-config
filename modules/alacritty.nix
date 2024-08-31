{...}: {
  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "zsh";
      };

      env = {
        "TERM" = "xterm-256color";
      };

      background_opacity = 0.75;

      window = {
        padding.x = 10;
        padding.y = 10;
        decorations = "buttonless";
      };

      font = {
        size = 12.0;
        use_thin_strokes = true;

        normal.family = "FiraCode Nerd Font";
        bold.family = "FiraCode Nerd Font";
        italic.family = "FiraCode Nerd Font";
      };
    };
  };
}