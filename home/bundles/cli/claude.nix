{
  pkgs,
  lib,
  ...
}:
let
  skillsDir = ./claude-skills;
  mkSkill =
    file:
    lib.nameValuePair ".claude/skills/${lib.removeSuffix ".md" file}/SKILL.md" {
      source = skillsDir + "/${file}";
    };
  skills = lib.listToAttrs (
    map mkSkill (lib.filter (lib.hasSuffix ".md") (builtins.attrNames (builtins.readDir skillsDir)))
  );

  claudeSettings = pkgs.writeText "claude-settings.json" (
    builtins.toJSON {
      permissions = {
        allow = [
          "WebSearch"
          "WebFetch"
          "Read"
          "Glob"
          "Grep"
          "Bash(git status:*)"
          "Bash(git log:*)"
          "Bash(git diff:*)"
          "Bash(git branch:*)"
          "Bash(git show:*)"
          "Bash(cargo:*)"
          "Bash(jj status:*)"
          "Bash(jj log:*)"
          "Bash(jj diff:*)"
          "Bash(jj show:*)"
          "Bash(jj bookmark list:*)"
          "Bash(nix eval:*)"
          "Bash(nix flake show:*)"
          "Bash(nix flake metadata:*)"
          "Bash(nix flake info:*)"
          "Bash(nix flake check:*)"
          "Bash(nix search:*)"
          "Bash(nix path-info:*)"
          "Bash(nix derivation show:*)"
          "Bash(nix store ls:*)"
          "Bash(nix why-depends:*)"
          "Bash(nixos-option:*)"
          "Bash(nix build --dry-run:*)"
          "Bash(nix log:*)"
          "Bash(nix diff-closures:*)"
          "Bash(gh pr view:*)"
          "Bash(gh pr list:*)"
          "Bash(gh pr diff:*)"
          "Bash(gh pr checks:*)"
          "Bash(gh issue view:*)"
          "Bash(gh issue list:*)"
          "Bash(gh run list:*)"
          "Bash(gh run view:*)"
          "Bash(gh release list:*)"
          "Bash(gh release view:*)"
          "Bash(gh repo view:*)"
          "Bash(gh api repos:*)"
        ];
        additionalDirectories = [
          "/home/jack/code"
          "/nix"
        ];
      };
      enabledPlugins = {
        "rust-analyzer-lsp@claude-plugins-official" = true;
      };
    }
  );
in
{
  home.file = skills // {
    ".claude/CLAUDE.md".text = ''
      All repos live under ~/code/ with paths matching the git remote URL.
      For example, the repo `github.com/<org>/<repo>` is cloned to `~/code/github.com/<org>/<repo>`.

      For repos under ~/code/github.com/utilidata: only some developers on the team use Nix. Default documentation and setup instructions should target a standard Ubuntu/Debian-like environment. Nix flakes should be kept correct and up to date, but documented as an alternative path, not the primary one.
      Format code after making changes (e.g. cargo fmt). Use `make commitready` or similar if available.
      Prefer jj over git.
    '';
  };

  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD install -Dm644 ${claudeSettings} $HOME/.claude/settings.json
    $DRY_RUN_CMD chmod u+w $HOME/.claude/settings.json
  '';
}
