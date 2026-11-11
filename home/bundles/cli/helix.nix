{ ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      editor = {
        bufferline = "always";
        file-picker.hidden = false;
        lsp.display-inlay-hints = true;
      };
    };

    languages = {
      # ruff-lsp is gone from nixpkgs; its replacement is built into ruff
      # itself. The old --ignore=E203,W503 isn't carried over: ruff doesn't
      # implement W503 and leaves E203 off by default.
      language-server.ruff = {
        command = "ruff";
        args = [ "server" ];
        config.settings.lineLength = 79;
      };

      language-server.pylsp.config.pylsp.plugins = {
        pylint.enabled = true;
      };

      language = [
        {
          name = "python";
          language-servers = [
            "ruff"
            "pylsp"
          ];
          auto-format = true;
        }
        {
          name = "nix";
          formatter.command = "nixfmt";
          auto-format = true;
        }
      ];
    };
  };
}
