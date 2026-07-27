#!/bin/bash


echo "Installing dev dependencies..."

echo "Installing graphify..."
uv tool install graphifyy 

graphify install

echo "Graphify installed successfully."

echo "Installing floci..."

curl -fsSL https://floci.io/install.sh | sh

echo "Starting dev environment..."
chmod +x ./iac/environments/dev/init.sh
./iac/environments/dev/init.sh





