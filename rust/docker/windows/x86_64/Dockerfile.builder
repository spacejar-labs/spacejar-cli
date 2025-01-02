# docker/windows/x86_64/Dockerfile.builder
# Purpose: Builds spacejar CLI for Windows x86_64 (Intel/AMD 64-bit)
# Usage:
# docker build -t spacejar/windows-x86_64-builder -f docker/windows/x86_64/Dockerfile.builder .
# docker run --rm \
#   --platform linux/amd64 \
#   -v "$(pwd)/src:/usr/src/app/src" \
#   -v "$(pwd)/crates:/usr/src/app/crates" \
#   -v "$(pwd)/Cargo.toml:/usr/src/app/Cargo.toml" \
#   -v "$(pwd)/Cargo.lock:/usr/src/app/Cargo.lock" \
#   -v "$(pwd)/version.txt:/usr/src/app/version.txt" \
#   -v "$(pwd)/scripts:/usr/local/scripts" \
#   -v "$(pwd)/binaries:/usr/src/app/binaries" \
#   spacejar/windows-x86_64-builder

FROM --platform=linux/amd64 rust:latest

# Install build tools for Windows x86_64 cross-compilation
RUN apt-get update && apt-get install -y \
    gcc-mingw-w64-x86-64 \
    g++-mingw-w64-x86-64 \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Add Windows target
RUN rustup target add x86_64-pc-windows-gnu

WORKDIR /usr/src/app

ENTRYPOINT ["/usr/local/scripts/build/windows/x86_64.sh"]