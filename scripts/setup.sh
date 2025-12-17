#!/usr/bin/env bash
set -e

(
    git submodule update --init &&
    ./scripts/remap.sh &&
    ./scripts/decompile.sh
) || {
    echo "Failed to complete setup."
    exit 1
}
