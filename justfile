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

test: build
    ./scripts/test-keymaps.sh

sync-remote:
    git fetch --all
    git pull origin main
    git pull forgejo main
    git push origin main
    git push forgejo main
