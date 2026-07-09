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
# TODO: implement starship build

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

echo "build_debian.sh for starship is not implemented yet."
exit 1
