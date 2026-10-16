# Deploy NixOS server via nixos-rebuild --target-host
# Override: just HOST=root@other switch  |  just FLAKE=.#nixos switch
HOST := "root@193.33.111.100"
FLAKE := ".#default"

default:
    @just --list

# Local flake eval check (no build)
check:
    nix flake check --no-build

# Update flake inputs, then check
update:
    nix flake update && nix flake check --no-build

# Build and show what would activate on the server, without changing it
dry:
    nixos-rebuild dry-activate --flake {{FLAKE}} --target-host {{HOST}}

# Activate temporarily (reverts on reboot) — good for risky tests
test:
    nixos-rebuild test --flake {{FLAKE}} --target-host {{HOST}}

# Build + activate now
switch: check
    nixos-rebuild switch --flake {{FLAKE}} --target-host {{HOST}}

# Build + activate on next reboot (safer for networking/bootloader changes)
boot: check
    nixos-rebuild boot --flake {{FLAKE}} --target-host {{HOST}}

# Revert server to previous generation
rollback:
    ssh {{HOST}} "nixos-rebuild switch --rollback"

# Quick SSH shell
ssh:
    ssh {{HOST}}

# Journal logs on server: just logs nginx  |  just logs livebook
logs service="nginx":
    ssh {{HOST}} "journalctl -u {{service}} -e --no-pager"

# Fresh install via nixos-anywhere (repartitions disk! not for routine updates)
install:
    nixos-anywhere --flake ./nixos-anywhere#generic {{HOST}}
