# nix-config

NixOS and Home Manager configurations for my machines.

## Structure

```
flake.nix              # Entry point — defines all hosts via mkHost, recovery ISOs via mkIso
justfile               # Task runner (build, switch, update, fmt, check, iso, …)
shell.nix              # Dev shell for bootstrapping nix + home-manager

host/
  bundles/
    global/            # Shared NixOS settings applied to all hosts
    desktop/           # Desktop environment, 1Password, etc.
    i3/                # i3 / X11 system-level bits
    yocto-flashing/    # Host tooling for flashing Yocto images (udisks2, udev rules)
  lobotomizer/         # Per-host NixOS config + hardware (+ disko.nix where used)
  ossifier/
  giza-power-plant/
  beguiler/
  vitrifier/

home/
  global/              # Shared Home Manager settings applied to all hosts
  bundles/
    cli/               # CLI tools: git, helix, zsh, starship, zellij, etc.
    desktop/           # GUI apps: alacritty, flameshot, etc.
    i3/                # i3 wm, rofi, picom, autorandr, status bar, stylix theming
    game/              # Gaming: lutris, heroic, wine
    nvidia/            # NVIDIA-specific home config
    work/              # Work-specific packages
  lobotomizer.nix      # Per-host home config (imports relevant bundles)
  ossifier.nix
  giza-power-plant.nix
  beguiler.nix
  vitrifier.nix

modules/nixos/         # Reusable NixOS modules (e.g. iso.nix)

assets/                # Wallpapers and other static assets

pkgs/                  # Custom package derivations (see pkgs/README.md)
```

## Usage

Common tasks are wrapped in the [`justfile`](./justfile), which drives
[`nh`](https://github.com/viperML/nh) under the hood. Run `just` (or
`just --list`) to see every recipe; the most common ones:

```sh
just switch        # build & activate the current host
just build         # build only, no activation
just test          # activate without adding a boot entry
just update-switch # update flake inputs, then switch
just fmt           # format all files (treefmt)
just check         # nix flake check
just hosts         # list available hosts
```

The recipes target `$(hostname)` automatically. To act on a different host,
invoke `nh` directly, e.g. `nh os switch . --hostname <hostname>`.

### Add a new host

1. Create `host/<hostname>/configuration.nix` and `hardware-configuration.nix`
   (add `disko.nix` and list the host in `diskoHosts` in `flake.nix` if it uses
   disko)
2. Create `home/<hostname>.nix` importing the bundles you want
3. Add the hostname to the `nixosConfigurations` list in `flake.nix`

### Update dependencies

```sh
just update        # nix flake update
```

### Bootstrap on a fresh install

```sh
nix develop  # enters a shell with nix and home-manager available
```

A recovery ISO can be built for ISO-enabled hosts with `just iso <host>`.

## Packages

This flake exposes custom packages (e.g. `claude-code`) as flake outputs and via
`overlays.default`, so they can be used standalone — no need to clone the repo:

```sh
nix run github:jack-kelly/nix-config#claude-code
```

See [`pkgs/README.md`](./pkgs/README.md) for the full list and instructions on
consuming them from your own flake or overlay.
