#!/usr/bin/env bash

JAR_PATH="temp/1.8.8.jar"
JAR_URL="https://piston-data.mojang.com/v1/objects/5fafba3f58c40dc51b5c3ca72a98f62dfdae1db7/server.jar"

mkdir -p temp

if [ ! -f "$JAR_PATH" ]; then
  echo "Downloading vanilla server jar..."

  if ! curl -s -o "$JAR_PATH" "$JAR_URL"; then
    echo "Error: failed to download vanilla server jar."
    exit 1
  fi
fi
