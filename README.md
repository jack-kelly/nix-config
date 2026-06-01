# nix-config

NixOS and Home Manager configurations for my machines.

## Structure

```
flake.nix              # Entry point — defines all hosts via mkHost
shell.nix              # Dev shell for bootstrapping nix + home-manager

host/
  bundles/
    global/            # Shared NixOS settings applied to all hosts
    desktop/           # Desktop environment, 1Password, etc.
  wungus/              # Per-host NixOS config + hardware
  ues-safe-travels/
  hopoo/

home/
  global/              # Shared Home Manager settings applied to all hosts
  bundles/
    cli/               # CLI tools: git, helix, zsh, starship, zellij, etc.
    desktop/           # GUI apps: alacritty, flameshot, etc.
    game/              # Gaming: lutris, heroic, wine
    work/              # Work-specific packages
  wungus.nix           # Per-host home config (imports relevant bundles)
  ues-safe-travels.nix
  hopoo.nix

modules/nixos/         # Reusable NixOS modules

pkgs/                  # Custom package derivations (see pkgs/README.md)
```

## Usage

### Apply system configuration

```sh
sudo nixos-rebuild switch --flake .#<hostname>
```

### Add a new host

1. Create `host/<hostname>/configuration.nix` and `hardware-configuration.nix`
2. Create `home/<hostname>.nix` importing the bundles you want
3. Add the hostname to the list in `flake.nix`

### Update dependencies

```sh
nix flake update
```

### Bootstrap on a fresh install

```sh
nix develop  # enters a shell with nix and home-manager available
```

## Packages

This flake exposes custom packages (e.g. `claude-code`) as flake outputs and via
`overlays.default`, so they can be used standalone — no need to clone the repo:

```sh
nix run github:jack-kelly/nix-config#claude-code
```

See [`pkgs/README.md`](./pkgs/README.md) for the full list and instructions on
consuming them from your own flake or overlay.
