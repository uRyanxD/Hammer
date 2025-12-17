#!/usr/bin/env bash
set -e

basedir="$(pwd -P)"
TEMP_DIR="$basedir/temp"
MINECRAFT_VERSION="1.8.8"
VANILLA_JAR="$TEMP_DIR/$MINECRAFT_VERSION"

JAR_URL="https://piston-data.mojang.com/v1/objects/5fafba3f58c40dc51b5c3ca72a98f62dfdae1db7/server.jar"

mkdir -p "$TEMP_DIR"

if [ ! -f "$VANILLA_JAR.jar" ]; then
  echo "Downloading vanilla server jar..."
  if ! curl -s -o "$VANILLA_JAR.jar" "$JAR_URL"; then
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
ACTUAL_HASH=$(md5_file "$VANILLA_JAR.jar")

if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
  echo "Vanilla server jar checksum mismatch."
  exit 1
fi

CLASS_MAPPINGS="BuildData/mappings/$(grep '"classMappings"' BuildData/info.json | cut -d '"' -f 4)"
MEMBER_MAPPINGS="BuildData/mappings/$(grep '"memberMappings"' BuildData/info.json | cut -d '"' -f 4)"
PACKAGE_MAPPINGS="BuildData/mappings/$(grep '"packageMappings"' BuildData/info.json | cut -d '"' -f 4)"
ACCESS_TRANSFORMS="BuildData/mappings/$(grep '"accessTransforms"' BuildData/info.json | cut -d '"' -f 4)"

if [ ! -f "${VANILLA_JAR}-cm.jar" ]; then
  echo "Applying class mappings..."
  if ! java -jar bin/SpecialSource-2.jar map \
        --auto-lvt BASIC \
        -i "$VANILLA_JAR.jar" \
        -m "$CLASS_MAPPINGS" \
        -o "${VANILLA_JAR}-cm.jar" > /dev/null 2>&1; then
    echo "Failed to apply class mappings."
    exit 1
  fi
fi

if [ ! -f "${VANILLA_JAR}-mm.jar" ]; then
  echo "Applying member mappings..."
  if ! java -jar bin/SpecialSource-2.jar map \
        --auto-member TOKENS \
        -i "${VANILLA_JAR}-cm.jar" \
        -m "$MEMBER_MAPPINGS" \
        -o "${VANILLA_JAR}-mm.jar" > /dev/null 2>&1; then
    echo "Failed to apply member mappings."
    exit 1
  fi
fi

if [ ! -f "${VANILLA_JAR}-mapped.jar" ]; then
  echo "Creating remapped jar..."
  if ! java -jar bin/SpecialSource.jar \
        -i "${VANILLA_JAR}-mm.jar" \
        --access-transformer "$ACCESS_TRANSFORMS" \
        -m "$PACKAGE_MAPPINGS" \
        -o "${VANILLA_JAR}-mapped.jar" > /dev/null 2>&1; then
    echo "Failed to create remapped jar."
    exit 1
  fi
fi
