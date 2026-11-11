{
  programs.pi-coding-agent = {
    enable = true;

    # Shared verbatim with Claude Code's ~/.claude/CLAUDE.md (see
    # ../cli/claude.nix). pi loads it as its global AGENTS.md.
    context = ../../agent-instructions.md;
  };
}
