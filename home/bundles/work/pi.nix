{ ... }:
{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/pi-coding-agent.nix
  programs.pi-coding-agent = {
    enable = true;

    # Shared verbatim with Claude Code's ~/.claude/CLAUDE.md -- see
    # ../cli/claude.nix. pi loads this as its global AGENTS.md, then layers
    # parent-dir and cwd AGENTS.md/CLAUDE.md on top.
    context = ../../agent-instructions.md;

    # Unlike claude.nix's settings.json, there's no permissions.allow to set
    # here: pi ships no permission-popup / allowlist system by default. See
    # https://github.com/czottmann/pi-automode for an LLM-classifier-based
    # guardrail extension, added declaratively via `settings.packages` below
    # if we decide to opt in.
    settings = {
      # packages = [ "npm:@czottmann/pi-automode" ];
    };
  };
}
