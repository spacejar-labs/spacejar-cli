#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Installing SpaceJar CLI...${NC}"

# Detect OS and architecture
detect_platform() {

    case "$(uname -s)" in
        Darwin*)
            os="darwin"
            ;;
        Linux*)
            os="linux"
            ;;
        *)
            echo -e "${RED}Unsupported OS.${NC}"
            exit 1
            ;;
    esac

    # Detect architecture
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        arm64|aarch64)
            arch="aarch64"
            ;;
        *)
            echo -e "${RED}Unsupported architecture.${NC}"
            exit 1
            ;;
    esac

    >&2 echo "os=${os}, arch=${arch}"
}

get_latest_version() {
    >&2 echo -e "${BLUE}Getting latest version...${NC}"
    local latest_release
    latest_release=$(curl -sL https://api.github.com/repos/spacejar-labs/spacejar-cli/releases/latest)

    if [ -z "$latest_release" ]; then
        >&2echo -e "${RED}Failed to get latest version from Github.${NC}"
        exit 1
    fi

    local version
    version=$(echo "$latest_release" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "$version"
}


setup_install_dir() {
    local install_dir="${HOME}/.local/bin"
    mkdir -p "${install_dir}"
    >&2 echo -e "${BLUE}Install directory set to ${install_dir}${NC}"
    echo "${install_dir}"
}

detect_shell_config() {
    if [ -n "${ZSH_VERSION:-}" ]; then
        SHELL_CONFIG="${HOME}/.zshrc"
    elif [ -n "${BASH_VERSION:-}" ]; then
        if [ -f "${HOME}/.bashrc" ]; then
            SHELL_CONFIG="${HOME}/.bashrc"
        else
            SHELL_CONFIG="${HOME}/.bash_profile"
        fi
    else
        SHELL_CONFIG="${HOME}/.profile"
    fi
    echo "${SHELL_CONFIG}"
}

update_path() {
    local install_dir="$1"
    local shell_config="$2"
    if ! echo "${PATH}" | tr ':' '\n' | grep -q "^${install_dir}$"; then
        if ! grep -q "export PATH=\"\${HOME}/.local/bin:\${PATH}\"" "${shell_config}"; then
            echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> "${shell_config}"
            echo -e "${GREEN}Added ${install_dir} to PATH in ${shell_config}.${NC}"
        fi
    fi
}

install_binary() {
    local os="$1"
    local arch="$2"
    local version="$3"
    local install_dir="$4"
    local temp_dir
    temp_dir=$(mktemp -d)
    trap 'rm -rf "'"$temp_dir"'"' EXIT
    local filename="spacejar-${version}-${os}-${arch}.tar.gz"
    local url="https://github.com/spacejar-labs/spacejar-cli/releases/download/${version}/${filename}"
    echo -e "${BLUE}Downloading spacejar ${version} for ${os}/${arch}...${NC}"
    if ! curl -SL "${url}" | tar -xz -C "${temp_dir}"; then
        echo -e "${RED}Failed to download or extract ${filename}.${NC}"
        exit 1
    fi
    mv "${temp_dir}/spacejar" "${install_dir}/"
    chmod +x "${install_dir}/spacejar"
}

main() {
    detect_platform
    version=$(get_latest_version)
    install_dir=$(setup_install_dir)
    install_binary "${os}" "${arch}" "${version}" "${install_dir}"
    shell_config=$(detect_shell_config)
    update_path "${install_dir}" "${shell_config}"

    echo -e "${GREEN}Spacejar CLI installed successfully.${NC}"

    if [ -x "$install_dir/spacejar" ]; then
        echo -e "${BLUE}Verifying installation...${NC}"
        echo -e "${GREEN}Installed version:${NC}"
        "${install_dir}/spacejar" --version
        echo -e "${GREEN}To use spacejar, restart your terminal or type ${BLUE}source ${shell_config}${GREEN} to reload your shell configuration.${NC}"
    else
        echo -e "${RED}Installation verification failed${NC}"
        exit 1
    fi
}

main