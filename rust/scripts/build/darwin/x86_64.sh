#!/bin/bash
# Purpose: Build script for macOS x86_64 target
set -e

# Set variables
VERSION=$(cat version.txt)
TARGET="x86_64-apple-darwin"
BINARY_NAME="spacejar"
OUTPUT_DIR="binaries/darwin/${TARGET}"
RELEASE_NAME="spacejar-v${VERSION}-darwin-x86_64"

echo "Building Darwin x86_64 binary..."

cd /usr/src/app

echo "Building version ${VERSION} for ${TARGET}"
echo "Output directory: ${OUTPUT_DIR}"

# Build using cargo-zigbuild
MACOSX_DEPLOYMENT_TARGET=10.7 \
cargo zigbuild --release --target ${TARGET}

mkdir -p "${OUTPUT_DIR}"

cp "target/${TARGET}/release/${BINARY_NAME}" "${OUTPUT_DIR}/"

cd "${OUTPUT_DIR}"

echo "Creating compressed archive..."
tar -czf "${RELEASE_NAME}.tar.gz" "${BINARY_NAME}"

echo "Creating checksum..."
sha256sum "${RELEASE_NAME}.tar.gz" > "${RELEASE_NAME}.tar.gz.sha256"

echo "Verifying checksum..."
sha256sum -c "${RELEASE_NAME}.tar.gz.sha256"

echo "Build completed successfully!"
echo "Build artifacts in ${OUTPUT_DIR}:"
ls -la

echo "Binary path: ${OUTPUT_DIR}/${BINARY_NAME}"
echo "Archive path: ${OUTPUT_DIR}/${RELEASE_NAME}.tar.gz"
echo "Checksum path: ${OUTPUT_DIR}/${RELEASE_NAME}.tar.gz.sha256"
