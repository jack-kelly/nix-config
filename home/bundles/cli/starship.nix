{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
      };

      # Disable built-in git modules (replaced by custom modules below)
      git_status.disabled = true;
      git_commit.disabled = true;
      git_metrics.disabled = true;
      git_branch.disabled = true;

      custom = {
        # Custom module for jj status
        jj = {
          description = "The current jj status";
          when = "jj --ignore-working-copy root";
          symbol = "🥋 ";
          command = ''
            jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
              separate(" ",
                change_id.shortest(4),
                bookmarks,
                "|",
                concat(
                  if(conflict, "💥"),
                  if(divergent, "🚧"),
                  if(hidden, "👻"),
                  if(immutable, "🔒"),
                ),
                raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
                raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                  truncate_end(80, description.first_line(), "…"),
                  "(no description set)",
                ) ++ raw_escape_sequence("\x1b[0m"),
              )
            '
          '';
        };

        # Git modules that only show when not in a jj repo
        git_status = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_status";
          style = "";
          description = "Only show git_status if we're not in a jj repo";
        };

        git_commit = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_commit";
          style = "";
          description = "Only show git_commit if we're not in a jj repo";
        };

        git_metrics = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_metrics";
          style = "";
          description = "Only show git_metrics if we're not in a jj repo";
        };

        git_branch = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_branch";
          style = "";
          description = "Only show git_branch if we're not in a jj repo";
        };
      };
    };
  };
}
