# nix-config

NixOS and Home Manager configurations for my machines.

## Structure

```
flake.nix              # Entry point: builds every host with mkHost
justfile               # Task runner (run `just` to list recipes)

host/
  <hostname>/          # NixOS config + hardware (+ disko.nix where used)
  bundles/
    global/            # Applied to every host
    desktop/           # Base for graphical hosts: X, audio, 1Password
    i3/                # i3 on top of desktop
    work/              # Tailscale, Docker
    ups/               # NUT for the CyberPower UPS
    webcam/            # v4l2loopback, phone-as-webcam
    yocto-flashing/    # Tooling for flashing Yocto/Jetson images

home/
  <hostname>.nix       # Home Manager entrypoint; imports the bundles it wants
  global/              # Applied to every host (pulls in cli)
  bundles/
    cli/               # Shell, editor, git/jj, CLI tools
    desktop/           # GUI apps: alacritty, firefox, zellij
    i3/                # i3, status bar, rofi, picom, autorandr, stylix theming
    nvidia/            # GPU monitoring
    work/              # Work packages

pkgs/                  # Custom packages (see pkgs/README.md)
assets/                # Wallpapers
```

## Usage

The [`justfile`](./justfile) wraps [`nh`](https://github.com/viperML/nh) and
targets the current hostname:

```sh
just switch        # build & activate
just build         # build only
just test          # activate without adding a boot entry
just update        # nix flake update
just update-switch # update, then switch
just fmt           # format (treefmt)
just check         # nix flake check
```

For another host, call `nh` directly: `nh os switch . --hostname <hostname>`.

`nix develop` gives a bootstrap shell with everything the recipes need.

### Add a new host

1. Create `host/<hostname>/configuration.nix` and `hardware-configuration.nix`
   (plus `disko.nix` if it uses disko; it is picked up automatically)
2. Create `home/<hostname>.nix` importing the bundles you want
3. Add the hostname to the `nixosConfigurations` list in `flake.nix`

### Reinstall a host

Hosts with a `disko.nix` can be wiped and reinstalled from another machine with
[`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere):

1. Boot the target from a stock NixOS installer image and get it on the network.
2. On the target, set a root password (`sudo passwd`) and note its IP (`ip a`).
3. From a working checkout of this repo:

   ```sh
   just install <hostname> <target-ip>
   ```

This **erases the target's disk**: it partitions and formats per the host's
`disko.nix` (prompting for the LUKS passphrase), installs the flake's
configuration, and reboots. `jack` has no declared password, so after first boot
SSH in with the authorized key and set one before logging in at the console.

Hosts without a `disko.nix` are installed the manual way: stock installer, then
`just switch` after first boot.

## Packages

Custom packages (e.g. `claude-code`) are exposed as flake outputs and through
`overlays.default`:

```sh
nix run github:jack-kelly/nix-config#claude-code
```

See [`pkgs/README.md`](./pkgs/README.md) for using them from another flake.
