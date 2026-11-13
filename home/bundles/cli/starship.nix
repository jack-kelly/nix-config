{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # `$all` doesn't include `$vcs` and would re-render the git modules, so
      # this is `$all` with the per-VCS modules swapped for `$vcs`.
      format = builtins.concatStringsSep "" [
        "$username$hostname$localip$shlvl$singularity$kubernetes$nats$directory"
        "$vcsh$vcs$custom"
        "$docker_context$package$bun$c$cmake$cobol$cpp$daml$dart$deno$dotnet$elixir$elm$erlang$fennel"
        "$fortran$gleam$golang$gradle$haskell$haxe$helm$java$julia$kotlin$lua$maven$mojo$nim$nodejs"
        "$ocaml$odin$opa$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust$scala"
        "$solidity$swift$terraform$typst$vlang$vagrant$xmake$zig$buf$guix_shell$nix_shell$conda$pixi"
        "$meson$spack$memory_usage$aws$gcloud$openstack$azure$direnv$env_var$mise$crystal$sudo"
        "$cmd_duration$line_break$jobs$battery$time$status$container$netns$os$shell$character"
      ];

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
      };

      # Built-in jj_change doesn't show the description. Empty output hides
      # the module; jj_status already shows ◌ for an empty description.
      custom.jj_description = {
        when = "jj --ignore-working-copy root";
        command = ''jj log -r @ --no-graph --ignore-working-copy --limit 1 -T 'truncate_end(80, description.first_line(), "…")' '';
        style = "bold green";
        format = "[$output]($style) ";
      };

      # Prefer jj over git in colocated repos
      vcs.order = [
        "jj"
        "git"
      ];
    };
  };
}
