#!/usr/bin/env bash
set -e

SRC_DIR="server/src/main/java"
TEMP_DIR="temp"
MINECRAFT_VERSION="1.8.8"
VANILLA_JAR="$TEMP_DIR/$MINECRAFT_VERSION"
MAPPED_JAR="${VANILLA_JAR}-mapped.jar"

if [ ! -d "$SRC_DIR" ]; then
  echo "Decompiling mapped jar..."

  if ! java -jar bin/Vineflower.jar \
        -dgs=1 -hdc=0 -asc=1 -udv=0 -rsy=1 -aoa=1 \
        "$MAPPED_JAR" "$SRC_DIR"; then
    echo "Failed to decompile mapped jar."
    exit 1
  fi
fi
