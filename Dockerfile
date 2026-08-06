# syntax=docker/dockerfile:1

ARG ANKI_VERSION

# Compile on the runner's architecture. The workflow uses an arm64 runner for
# the arm64 image; the 32-bit targets are cross-compiled inside this stage.
FROM --platform=$BUILDPLATFORM docker.io/library/rust:bookworm AS build

ARG ANKI_VERSION
ARG BUILDARCH
ARG TARGETARCH

WORKDIR /src

RUN set -eux; \
    foreign_packages=""; \
    case "$TARGETARCH:$BUILDARCH" in \
        amd64:amd64|arm64:arm64) \
            compiler_packages="gcc g++"; \
            ;; \
        amd64:arm64) \
            compiler_packages="gcc-x86-64-linux-gnu g++-x86-64-linux-gnu"; \
            dpkg --add-architecture amd64; \
            foreign_packages="libc6-dev:amd64"; \
            ;; \
        386:amd64) \
            compiler_packages="gcc-i686-linux-gnu g++-i686-linux-gnu"; \
            ;; \
        arm:amd64) \
            compiler_packages="gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf"; \
            ;; \
        arm64:amd64) \
            compiler_packages="gcc-aarch64-linux-gnu g++-aarch64-linux-gnu"; \
            ;; \
        *) \
            echo "Unsupported build/target architecture: $BUILDARCH/$TARGETARCH" >&2; \
            exit 1; \
            ;; \
    esac; \
    apt-get update; \
    apt-get install --no-install-recommends --yes \
        ca-certificates \
        git \
        protobuf-compiler \
        $compiler_packages \
        $foreign_packages; \
    rm -rf /var/lib/apt/lists/*; \
    git clone --branch "$ANKI_VERSION" --depth 1 --recurse-submodules \
        https://github.com/ankitects/anki.git .

RUN set -eux; \
    case "$TARGETARCH" in \
        amd64) \
            rust_target="x86_64-unknown-linux-gnu"; \
            ;; \
        386) \
            rust_target="i686-unknown-linux-gnu"; \
            ;; \
        arm64) \
            rust_target="aarch64-unknown-linux-gnu"; \
            ;; \
        arm) \
            rust_target="armv7-unknown-linux-gnueabihf"; \
            ;; \
        *) \
            echo "Unsupported target architecture: $TARGETARCH" >&2; \
            exit 1; \
            ;; \
    esac; \
    rustup target add "$rust_target"; \
    build_server() { \
        PROTOC="$(command -v protoc)" \
        RUSTFLAGS='-C target-feature=+crt-static' \
        cargo build --release --target "$rust_target" --package anki-sync-server; \
    }; \
    case "$TARGETARCH:$BUILDARCH" in \
        amd64:amd64|arm64:arm64) \
            build_server; \
            ;; \
        amd64:arm64) \
            CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=x86_64-linux-gnu-gcc build_server; \
            ;; \
        386:*) \
            CARGO_TARGET_I686_UNKNOWN_LINUX_GNU_LINKER=i686-linux-gnu-gcc build_server; \
            ;; \
        arm64:amd64) \
            CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc build_server; \
            ;; \
        arm:*) \
            CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc build_server; \
            ;; \
    esac; \
    install -D -m 755 "target/$rust_target/release/anki-sync-server" \
        /out/anki-sync-server

FROM docker.io/library/alpine:latest

COPY --from=build /out/anki-sync-server /usr/local/bin/anki-sync-server

ENV \
    # Stores data in /config (VOLUME for persistence)
    SYNC_BASE="/config" \
    # Set default port
    SYNC_PORT="27701"

# Don't forget to set at least SYNC_USER1
CMD [ "/usr/local/bin/anki-sync-server" ]
