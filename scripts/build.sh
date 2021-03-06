#!/bin/bash

# This script builds the application from source for multiple platforms.
set -e

VERSION=${VERSION:-(dev)}
BINARY=${BINARY:-delmo}

# Get the parent directory of where this script is.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

# Change into that directory
cd "$DIR"

# Delete the old dir
echo "==> Removing old directory..."
rm -f bin/*
rm -rf pkg/*
mkdir -p bin

TARGETS=${TARGETS:-linux/amd64 darwin/amd64}
# If its dev mode, only build for ourself
if [[ ! -z "${DELMO_DEV}" ]]; then
  TARGETS=$(go env GOOS)/$(go env GOARCH)
fi


# Build!
echo "==> Building..."
gox -osarch="${TARGETS}" --output="pkg/${BINARY}-{{.OS}}-{{.Arch}}" -ldflags="-X main.Version=${VERSION}" ./...

DEV_BINARY="${BINARY}-$(go env GOOS)-$(go env GOARCH)"
MAIN_GOPATH=${GOPATH%%:*}
cp pkg/${DEV_BINARY} bin/${BINARY}
cp pkg/${DEV_BINARY} ${MAIN_GOPATH}/bin/${BINARY}

echo "Built version: $(bin/${BINARY} --version)"
