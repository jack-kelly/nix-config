# pkgs

Custom package derivations not (yet) in nixpkgs.

| Package | Description |
| --- | --- |
| [`claude-code`](./claude-code) | Claude Code — Anthropic's AI coding assistant in your terminal |

## claude-code

A self-contained derivation that fetches Anthropic's prebuilt `claude` binary
from their CDN and wraps it with the runtime tools it expects on `PATH`
(`ripgrep`, `procps`, and on Linux `bubblewrap` + `socat`). The wrapper also
disables the auto-updater and installation checks so the Nix store copy stays
immutable.

Supported platforms: `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`,
`aarch64-darwin`.

> **Note:** the binary is unfree (`lib.licenses.unfree`). The flake's `packages`
> output already allows unfree so the `nix run` / `nix profile` commands below
> work as-is. When consuming via the overlay or a raw `callPackage`, you must set
> `nixpkgs.config.allowUnfree = true` (or export `NIXPKGS_ALLOW_UNFREE=1`)
> yourself.

### Use it without cloning (flake output)

```sh
# Run it once
nix run github:jack-kelly/nix-config#claude-code

# Install into your profile
nix profile install github:jack-kelly/nix-config#claude-code
```

### Use it from your own flake

Reference the package directly:

```nix
{
  inputs.jack-config.url = "github:jack-kelly/nix-config";

  outputs = { self, nixpkgs, jack-config, ... }: {
    # e.g. in home.packages or environment.systemPackages
    # jack-config.packages.${pkgs.system}.claude-code
  };
}
```

…or pull in the overlay so `pkgs.claude-code` exists across your config:

```nix
{
  inputs.jack-config.url = "github:jack-kelly/nix-config";

  # wherever you import nixpkgs / configure home-manager:
  nixpkgs.overlays = [ jack-config.overlays.default ];
  # then, anywhere:  pkgs.claude-code
}
```

### Use it by copying the folder

The derivation has no dependency on the rest of this repo, so you can drop
`pkgs/claude-code/` into any tree and call it directly:

```nix
home.packages = [ (pkgs.callPackage ./pkgs/claude-code { }) ];
```

`binName` can be overridden if you want the binary installed under a different
name: `pkgs.callPackage ./pkgs/claude-code { binName = "claude-code"; }`.

### Updating

```sh
./pkgs/claude-code/update.sh
```

Bumps to the latest version published on npm and refreshes the per-platform
`sha256` hashes by prefetching from Anthropic's CDN.
