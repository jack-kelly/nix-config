# NixOS Config

## Commands
```bash
just switch   # build & activate
just fmt      # nixfmt .
just check    # nix flake check
```

## Layout
- `host/<name>/` — NixOS system config; `host/bundles/` — shared system modules
- `home/<name>.nix` — home-manager entrypoint; `home/bundles/<bundle>/` — feature groups (cli, desktop, i3, work, game)
- Individual program configs live as separate files inside each bundle dir (e.g. `home/bundles/cli/helix.nix`)

## Patterns
- Bundles are imported or not — no `mkIf` toggling within bundles
- `pkgs-stable` (nixpkgs 26.05) is passed via `specialArgs`; use it for packages that break on unstable (obsidian: electron 43 renders a blank window)
- Theming: stylix + Catppuccin Mocha, configured in `home/bundles/i3/stylix.nix`
