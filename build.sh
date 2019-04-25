#!/bin/sh

set -e

docker build -t secp256k1 .
mkdir -p "bin"
rm -rf "bin"
mkdir -p "bin"
docker run -v "$(pwd)/bin:/data" secp256k1