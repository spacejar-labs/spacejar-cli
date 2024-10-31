# docker/linux/aarch64/Dockerfile.builder
# Purpose: Builds spacejar CLI for Linux aarch64 (64-bit ARM)
# Usage:
# docker build -t spacejar/linux-aarch64-builder -f docker/linux/aarch64/Dockerfile.builder .
# docker run --rm \
#   --platform linux/arm64 \
#   -v "$(pwd)/src:/usr/src/app/src" \
#   -v "$(pwd)/Cargo.toml:/usr/src/app/Cargo.toml" \
#   -v "$(pwd)/Cargo.lock:/usr/src/app/Cargo.lock" \
#   -v "$(pwd)/version.txt:/usr/src/app/version.txt" \
#   -v "$(pwd)/scripts:/usr/local/scripts" \
#   -v "$(pwd)/binaries:/usr/src/app/binaries" \
#   spacejar/linux-aarch64-builder

FROM --platform=linux/arm64 rust:latest

# Install build tools for aarch64
RUN apt-get update && apt-get install -y \
    gcc \
    musl-tools \
    && rm -rf /var/lib/apt/lists/*

# Add the aarch64 target
RUN rustup target add aarch64-unknown-linux-musl

WORKDIR /usr/src/app

ENTRYPOINT ["/usr/local/scripts/build/linux/aarch64.sh"]