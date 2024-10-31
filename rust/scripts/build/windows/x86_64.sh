#!/bin/bash
# scripts/build/windows/x86_64.sh
# Purpose: Builds spacejar CLI for Windows x86_64
# Used by: docker/windows/x86_64/Dockerfile.builder
set -e

# Set variables
VERSION=$(cat version.txt)
TARGET="x86_64-pc-windows-gnu"
BINARY_NAME="spacejar.exe"
OUTPUT_DIR="binaries/windows/${TARGET}"
RELEASE_NAME="spacejar-v${VERSION}-windows-x86_64"

echo "Building Windows x86_64 binary..."

cd /usr/src/app

echo "Building version ${VERSION} for ${TARGET}"
echo "Output directory: ${OUTPUT_DIR}"

# Build using cargo with MinGW toolchain
cargo build --release --target ${TARGET}

mkdir -p "${OUTPUT_DIR}"

cp "target/${TARGET}/release/${BINARY_NAME}" "${OUTPUT_DIR}/"

cd "${OUTPUT_DIR}"

echo "Creating compressed archive..."
zip "${RELEASE_NAME}.zip" "${BINARY_NAME}"

echo "Creating checksum..."
sha256sum "${RELEASE_NAME}.zip" > "${RELEASE_NAME}.zip.sha256"

echo "Verifying checksum..."
sha256sum -c "${RELEASE_NAME}.zip.sha256"

echo "Build completed successfully!"
echo "Build artifacts in ${OUTPUT_DIR}:"
ls -la

echo "Binary path: ${OUTPUT_DIR}/${BINARY_NAME}"
echo "Archive path: ${OUTPUT_DIR}/${RELEASE_NAME}.zip"
echo "Checksum path: ${OUTPUT_DIR}/${RELEASE_NAME}.zip.sha256"