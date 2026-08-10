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
    # Shared verbatim with pi's global AGENTS.md -- see ../work/pi.nix.
    ".claude/CLAUDE.md".source = ../../agent-instructions.md;
  };

  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD install -Dm644 ${claudeSettings} $HOME/.claude/settings.json
    $DRY_RUN_CMD chmod u+w $HOME/.claude/settings.json
  '';
}
