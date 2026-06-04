{ ... }:
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # Bind Ctrl-R to atuin's search, but leave Up/Down as normal zsh history.
    flags = [ "--disable-up-arrow" ];
    settings = {
      # Sync against atuin's public, end-to-end-encrypted server.
      sync_address = "https://api.atuin.sh";
      auto_sync = true;
      sync_frequency = "5m";
    };
  };
}
