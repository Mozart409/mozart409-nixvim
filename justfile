# https://just.systems

set unstable

default:
    just --list

clear:
    clear 

run: clear
    nix run .#nvim
