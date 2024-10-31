#!/bin/bash
# scripts/build/linux/aarch64.sh
# Purpose: Builds spacejar CLI for Linux aarch64
# Used by: docker/linux/aarch64/Dockerfile.builder
set -e

# Set variables
VERSION=$(cat version.txt)
TARGET="aarch64-unknown-linux-musl"
BINARY_NAME="spacejar"
OUTPUT_DIR="binaries/linux/${TARGET}"
RELEASE_NAME="spacejar-v${VERSION}-linux-aarch64"

echo "Building Linux aarch64 binary..."

cd /usr/src/app

echo "Building version ${VERSION} for ${TARGET}"
echo "Output directory: ${OUTPUT_DIR}"

cargo build --release --target ${TARGET}

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