#!/usr/bin/env bash

JAR_PATH="temp/1.8.8.jar"
JAR_URL="https://piston-data.mojang.com/v1/objects/5fafba3f58c40dc51b5c3ca72a98f62dfdae1db7/server.jar"

mkdir -p temp

if [ ! -f "$JAR_PATH" ]; then
  echo "Downloading vanilla server jar..."

  if ! curl -s -o "$JAR_PATH" "$JAR_URL"; then
    echo "Failed to download vanilla server jar."
    exit 1
  fi
fi

md5_file() {
  if command -v md5sum >/dev/null 2>&1; then
    md5sum "$1" | cut -d ' ' -f 1
  else
    md5 -r "$1" | cut -d ' ' -f 1
  fi
}

EXPECTED_HASH=$(grep '"minecraftHash"' BuildData/info.json | cut -d '"' -f 4)
ACTUAL_HASH=$(md5_file "$JAR_PATH")

if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
  echo "Vanilla server jar checksum mismatch."
  exit 1
fi
