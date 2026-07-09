#!/bin/bash
set -euo pipefail

# Upstream Linux architectures for starship (https://github.com/starship/starship):
#   amd64    -> starship-x86_64-unknown-linux-musl.tar.gz
#   arm64    -> starship-aarch64-unknown-linux-musl.tar.gz
#   armhf    -> starship-arm-unknown-linux-musleabihf.tar.gz
#   i386     -> starship-i686-unknown-linux-musl.tar.gz
#   riscv64  -> starship-riscv64gc-unknown-linux-musl.tar.gz
#
# amd64, arm64, armhf, i386 and riscv64. No ppc64el, s390x or armel.

starship_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$starship_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <starship_version> <build_version> [architecture]"
    echo "Example: $0 1.2.3 1 arm64"
    echo "Example: $0 1.2.3 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, armhf, i386, riscv64, all"
    exit 1
fi

# Function to map Debian architecture to starship release name
get_starship_release() {
    local arch=$1
    case "$arch" in
        "amd64")
            echo "starship-x86_64-unknown-linux-musl"
            ;;
        "arm64")
            echo "starship-aarch64-unknown-linux-musl"
            ;;
        "armhf")
            echo "starship-arm-unknown-linux-musleabihf"
            ;;
        "i386")
            echo "starship-i686-unknown-linux-musl"
            ;;
        "riscv64")
            echo "starship-riscv64gc-unknown-linux-musl"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local starship_release

    starship_release=$(get_starship_release "$build_arch")
    if [ -z "$starship_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64, armhf, i386, riscv64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $starship_release"

    # Clean up any previous builds for this architecture
    rm -rf "$starship_release" || true
    rm -f "${starship_release}.tar.gz" || true

    # Download and extract starship binary for this architecture
    # (the upstream tarball has no wrapping directory, so extract into one)
    if ! wget "https://github.com/starship/starship/releases/download/v${starship_VERSION}/${starship_release}.tar.gz"; then
        echo "❌ Failed to download starship binary for $build_arch"
        return 1
    fi

    mkdir -p "$starship_release"
    if ! tar -xf "${starship_release}.tar.gz" -C "$starship_release"; then
        echo "❌ Failed to extract starship binary for $build_arch"
        return 1
    fi

    rm -f "${starship_release}.tar.gz"

    # Build packages for appropriate Debian distributions
    # riscv64 is only supported in trixie (v13) and later, not in bookworm (v12)
    if [ "$build_arch" = "riscv64" ]; then
        declare -a arr=("trixie" "forky" "sid")
    else
        declare -a arr=("bookworm" "trixie" "forky" "sid")
    fi

    for dist in "${arr[@]}"; do
        FULL_VERSION="$starship_VERSION-${BUILD_VERSION}+${dist}_${build_arch}"
        echo "  Building $FULL_VERSION"

        if ! docker build . -t "starship-$dist-$build_arch" \
            --build-arg DEBIAN_DIST="$dist" \
            --build-arg starship_VERSION="$starship_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg STARSHIP_RELEASE="$starship_release"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "starship-$dist-$build_arch")"
        if ! docker cp "$id:/starship_$FULL_VERSION.deb" - > "./starship_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./starship_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    # Clean up extracted directory
    rm -rf "$starship_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building starship $starship_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures
    ARCHITECTURES=("amd64" "arm64" "armhf" "i386" "riscv64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la starship_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
