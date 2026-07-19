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
