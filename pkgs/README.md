# pkgs

Custom package derivations not (yet) in nixpkgs.

| Package | Description |
| --- | --- |
| [`claude-code`](./claude-code) | Claude Code — Anthropic's AI coding assistant in your terminal |
| [`rtk`](./rtk) | Rust Token Killer — compresses dev-command output to cut LLM token usage |

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

## rtk

[RTK](https://github.com/rtk-ai/rtk) ("Rust Token Killer") is a CLI proxy that
filters and compresses the output of common dev commands (`git`, `cargo`, `gh`,
`aws`, …) before it reaches an LLM's context, cutting token usage on those
commands by a large margin. It hooks into Claude Code via a `PreToolUse` hook.

Unlike `claude-code`, this is **built from source** with
`rustPlatform.buildRustPackage` against the tagged release — no prebuilt binary.
It's a single self-contained Rust binary (pure-Rust HTTP via `ureq`, bundled
SQLite), so there are no native runtime dependencies and it's free
(`Apache-2.0`) — no `allowUnfree` needed.

Supported platforms: all Unix (`lib.platforms.unix`).

### Use it without cloning (flake output)

```sh
# Run it once
nix run github:jack-kelly/nix-config#rtk

# Install into your profile
nix profile install github:jack-kelly/nix-config#rtk
```

### Use it from your own flake

```nix
{
  inputs.jack-config.url = "github:jack-kelly/nix-config";

  outputs = { self, nixpkgs, jack-config, ... }: {
    # e.g. in home.packages or environment.systemPackages
    # jack-config.packages.${pkgs.system}.rtk
  };
}
```

…or pull in the overlay so `pkgs.rtk` exists across your config:

```nix
{
  inputs.jack-config.url = "github:jack-kelly/nix-config";

  nixpkgs.overlays = [ jack-config.overlays.default ];
  # then, anywhere:  pkgs.rtk
}
```

### Use it by copying the folder

The derivation has no dependency on the rest of this repo:

```nix
home.packages = [ (pkgs.callPackage ./pkgs/rtk { }) ];
```

### Updating

```sh
./pkgs/rtk/update.sh
```

Bumps to the latest GitHub release and refreshes both the source `hash` and the
vendored-crates `cargoHash` (the latter by forcing a mismatch and reading the
correct value back out of the build error).
