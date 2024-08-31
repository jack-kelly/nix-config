{...}: {
  programs.git = {
    enable = true;
    difftastic.enable = true;
    userName = "Jack Kelly";
    userEmail = "jkelly@utilidata.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.pager = "less";
    };
  };
}
