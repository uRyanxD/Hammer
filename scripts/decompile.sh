#!/usr/bin/env bash
set -e

basedir="$(pwd -P)"
TEMP_DIR="$basedir/temp"
MINECRAFT_VERSION="1.8.8"
VANILLA_JAR="$TEMP_DIR/$MINECRAFT_VERSION"
MAPPED_JAR="${VANILLA_JAR}-mapped.jar"
CLASSES_DIR="$TEMP_DIR/classes"
DECOMPILE_DIR="$TEMP_DIR/decompiled"

if [ ! -d "$CLASSES_DIR" ]; then
  echo "Extracting classes..."

  mkdir "$CLASSES_DIR"
  cd "$CLASSES_DIR"

  if ! jar xf "$MAPPED_JAR" net/minecraft/server yggdrasil_session_pubkey.der assets; then
    echo "Failed to extract classes from mapped jar."
    exit 1
  fi

  cd "$basedir"
fi

if [ ! -d "$DECOMPILE_DIR" ]; then
  echo "Decompiling mapped classes..."

  if ! java -jar bin/Vineflower.jar \
        -dgs=1 -hdc=0 -asc=1 -udv=0 -rsy=1 -aoa=1 \
        "$CLASSES_DIR" "$DECOMPILE_DIR"; then
    echo "Failed to decompile mapped classes."
    exit 1
  fi
fi
