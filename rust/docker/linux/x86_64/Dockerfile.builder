# docker/linux/x86_64/Dockerfile.builder
# Usage:
# docker build -t spacejar/linux-x86_64-builder -f docker/linux/x86_64/Dockerfile.builder .
# docker run --rm \
#   --platform linux/amd64 \
#   -v "$(pwd)/src:/usr/src/app/src" \
#   -v "$(pwd)/Cargo.toml:/usr/src/app/Cargo.toml" \
#   -v "$(pwd)/Cargo.lock:/usr/src/app/Cargo.lock" \
#   -v "$(pwd)/version.txt:/usr/src/app/version.txt" \
#   -v "$(pwd)/scripts:/usr/local/scripts" \
#   -v "$(pwd)/binaries:/usr/src/app/binaries" \
#   spacejar/linux-x86_64-builder

FROM --platform=linux/amd64 rust:latest

# Install build tools for x86_64
RUN apt-get update && apt-get install -y \
    gcc \
    musl-tools \
    && rm -rf /var/lib/apt/lists/*

# Add the x86_64 target
RUN rustup target add x86_64-unknown-linux-musl

# Create directory structure
WORKDIR /usr/src/app

ENTRYPOINT ["/usr/local/scripts/build/linux/x86_64.sh"]