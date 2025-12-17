#!/usr/bin/env bash
set -e

(
    git submodule update --init &&
    ./remap.sh &&
    ./decompile.sh
) || {
    echo "Failed to complete setup."
    exit 1
}
