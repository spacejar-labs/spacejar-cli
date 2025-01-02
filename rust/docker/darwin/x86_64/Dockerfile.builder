# docker/darwin/x86_64/Dockerfile.builder
# Purpose: Builds spacejar CLI for macOS x86_64 (Intel)
# Usage:
# docker build -t spacejar/darwin-x86_64-builder -f docker/darwin/x86_64/Dockerfile.builder .
# docker run --rm \
#   --platform linux/amd64 \
#   -v "$(pwd)/src:/usr/src/app/src" \
#   -v "$(pwd)/crates:/usr/src/app/crates" \
#   -v "$(pwd)/Cargo.toml:/usr/src/app/Cargo.toml" \
#   -v "$(pwd)/Cargo.lock:/usr/src/app/Cargo.lock" \
#   -v "$(pwd)/version.txt:/usr/src/app/version.txt" \
#   -v "$(pwd)/scripts:/usr/local/scripts" \
#   -v "$(pwd)/binaries:/usr/src/app/binaries" \
#   spacejar/darwin-x86_64-builder

FROM --platform=linux/amd64 rust:latest

# Install build tools
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Zig
RUN wget https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz \
    && tar -xf zig-linux-x86_64-0.11.0.tar.xz \
    && mv zig-linux-x86_64-0.11.0 /usr/local/zig \
    && rm zig-linux-x86_64-0.11.0.tar.xz

# Add Zig to PATH
ENV PATH="/usr/local/zig:${PATH}"

# Add the macOS target
RUN rustup target add x86_64-apple-darwin

# Install cargo-zigbuild
RUN cargo install cargo-zigbuild

WORKDIR /usr/src/app

# Verify installations
RUN zig version && \
    command -v cargo-zigbuild

ENTRYPOINT ["/usr/local/scripts/build/darwin/x86_64.sh"]
