# NixOS Config

## Commands
```bash
just switch   # build & activate
just fmt      # treefmt (nixfmt)
just check    # nix flake check
```

## Layout
- `host/<name>/` — NixOS system config; `host/bundles/` — shared system modules
- `home/<name>.nix` — home-manager entrypoint; `home/bundles/<bundle>/` — feature groups
- Individual program configs live as separate files inside each bundle dir (e.g. `home/bundles/cli/helix.nix`)

## Patterns
- Bundles are imported or not — no `mkIf` toggling within bundles
- `pkgs-stable` (nixpkgs 26.05) is a module argument in both NixOS and home-manager modules; use it for packages that break on unstable, with a comment saying why
- A new file is invisible to the flake until jj/git has snapshotted it (run `jj st`)
