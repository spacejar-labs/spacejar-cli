#!/bin/bash
# Used by and mounted on docker/linux/x86_64/Dockerfile.builder upon run
# Any changes here do not require rebuilding the docker image
set -e

# Set variables
VERSION=$(cat version.txt)
TARGET="x86_64-unknown-linux-musl"
BINARY_NAME="spacejar"
OUTPUT_DIR="binaries/linux/${TARGET}"
RELEASE_NAME="spacejar-v${VERSION}-linux-x86_64"

echo "Building Linux x86_64 binary..."

# Ensure we're in the correct directory
cd /usr/src/app

# Show what we're building
echo "Building version ${VERSION} for ${TARGET}"
echo "Output directory: ${OUTPUT_DIR}"

# Build the binary
cargo build --release --target ${TARGET}

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Copy binary
cp "target/${TARGET}/release/${BINARY_NAME}" "${OUTPUT_DIR}/"

# Change to output directory for archive creation
cd "${OUTPUT_DIR}"

# Create compressed archive
echo "Creating compressed archive..."
tar -czf "${RELEASE_NAME}.tar.gz" "${BINARY_NAME}"

# Create checksum
echo "Creating checksum..."
sha256sum "${RELEASE_NAME}.tar.gz" > "${RELEASE_NAME}.tar.gz.sha256"

# Verify checksum
echo "Verifying checksum..."
sha256sum -c "${RELEASE_NAME}.tar.gz.sha256"

echo "Build completed successfully!"
echo "Build artifacts in ${OUTPUT_DIR}:"
ls -la

# Print paths for easier scripting
echo "Binary path: ${OUTPUT_DIR}/${BINARY_NAME}"
echo "Archive path: ${OUTPUT_DIR}/${RELEASE_NAME}.tar.gz"
echo "Checksum path: ${OUTPUT_DIR}/${RELEASE_NAME}.tar.gz.sha256"