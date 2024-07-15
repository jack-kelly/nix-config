{pkgs, ... }: {
	programs.zellij = {
           enable = true;
           settings = {
               theme = "one-half-dark";
               default_shell = "zsh";
           };
       };
}