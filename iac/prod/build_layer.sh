#!/bin/bash

echo "Building the project..."


SOURCE_DIR="/workspaces/NimbusDrive/shared"
BUILD_DIR="builds"
PYTHON_DIR="python"
OUTPUT_DIR="$BUILD_DIR/$PYTHON_DIR"
ZIP_FILE="nimbus_layer.zip"


rm -rf $OUTPUT_DIR $ZIP_FILE

mkdir -p $OUTPUT_DIR


echo "Installing dependencies..."
echo "Source directory: $SOURCE_DIR"


if [ -d "$SOURCE_DIR" ]; then
    echo "Found requirements.txt, installing dependencies..."

    cp -r $SOURCE_DIR/src/shared/*.py $OUTPUT_DIR/

    uv pip install -r $SOURCE_DIR/pyproject.toml --target $OUTPUT_DIR


    echo "Creating zip file..."


    exit 0

else
    echo "No requirements.txt found in $Source_DIR, skipping dependency installation."
    exit 1
fi



