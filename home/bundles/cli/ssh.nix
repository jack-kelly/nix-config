{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      personalgit = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_github_jack-kelly";
        IdentitiesOnly = true;
      };
      workgit = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };
    };
    includes = [
      "~/.ssh/config.work"
      "~/.ssh/config.d/*"
    ];
  };
}
