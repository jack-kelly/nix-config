{
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    settings = {
      user.name = "Jack Kelly";
      init.defaultBranch = "main";
      rerere.enabled = true;
      alias = {
        p = "pull --ff-only";
        ff = "merge --ff-only";
        graph = "log --decorate --oneline --graph";
      };
    };

    includes = [
      {
        condition = "gitdir:~/code/github.com/jack-kelly/";
        contents = {
          user = {
            email = "jpk.lly@gmail.com";
          };
        };
      }
      {
        condition = "gitdir:~/code/github.com/utilidata/";
        contents = {
          user = {
            email = "jkelly@utilidata.com";
          };
        };
      }
    ];

    lfs.enable = true;

    ignores = [
      ".direnv"
      ".env"
    ];
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };

}
