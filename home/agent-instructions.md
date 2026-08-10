All repos live under ~/code/ with paths matching the git remote URL.
For example, the repo `github.com/<org>/<repo>` is cloned to `~/code/github.com/<org>/<repo>`.

For repos under ~/code/github.com/utilidata: only some developers on the team use Nix. Default documentation and setup instructions should target a standard Ubuntu/Debian-like environment. Nix flakes should be kept correct and up to date, but documented as an alternative path, not the primary one.
Format code after making changes (e.g. cargo fmt). Use `make commitready` or similar if available.
Prefer jj over git.
