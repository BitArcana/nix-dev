# nix-dev

Portable Nix development environment with Neovim (nixvim), standard tools, and project profiles.

## Prerequisites

Nix must be installed on your system. On Debian/Ubuntu:

```bash
sudo apt install nix
sudo usermod -aG nix-users $USER
```

Log out and back in (or start a new shell) so the `nix-users` group membership takes effect.

## Usage

No cloning required. Run directly via GitHub:

```bash
# Base environment (Neovim + ripgrep, fd, fzf, git, bat, tmux)
nix develop github:BitArcana/nix-dev

# C++ profile (base + clangd, cmake, ninja, gdb)
nix develop github:BitArcana/nix-dev#cpp
```

Or locally after cloning:

```bash
nix develop .
nix develop .#cpp
```

## Profiles

| Command | Tools |
|---|---|
| `nix develop .` | Neovim, ripgrep, fd, fzf, git, bat, tmux |
| `nix develop .#cpp` | + clangd, cmake, ninja, gdb |

## Adding a profile

Create a new file in `profiles/`:

```nix
# profiles/rust.nix
{ pkgs, baseShell }:
pkgs.mkShell {
  inputsFrom = [ baseShell ];
  packages = [ pkgs.rustc pkgs.cargo pkgs.rust-analyzer ];
}
```

It is automatically available as `nix develop .#rust` — no changes to `flake.nix` needed.
