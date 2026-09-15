# https://just.systems

set unstable

default:
    just --list

clear:
    clear

run: clear
    nix run .#nvim

build: clear
    nix build --no-link .#nvim

# Runtime contracts (keymaps, prefix collisions, clean startup) in a headless nvim
test: build
    ./scripts/test-keymaps.sh

# Format Nix files (all, or the given paths)
fmt *files:
    alejandra {{ if files == "" { "." } else { files } }}

# Static checks: dead code, lint, formatting, sorted blocks
lint:
    deadnix --fail .
    statix check .
    alejandra --check .
    keep-sorted --mode lint $(git ls-files '*.nix' justfile lefthook.yml)

sync-remotes:
    git fetch --all
    git pull origin main
    git pull forgejo main
    git push origin main
    git push forgejo main
