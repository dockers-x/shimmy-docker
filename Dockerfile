FROM rust:1.88-slim-bookworm AS builder

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        build-essential \
        cmake \
        libclang-dev \
        libssl-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN cargo build --release --locked --features airframe,huggingface

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        ca-certificates \
        libdrm2 \
        libssl3 \
        libvulkan1 \
        mesa-vulkan-drivers \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --home-dir /app --uid 10001 shimmy \
    && mkdir -p /app/models \
    && chown -R shimmy:shimmy /app

COPY --from=builder /app/target/release/shimmy /usr/local/bin/shimmy

USER shimmy
WORKDIR /app
EXPOSE 11434

ENV SHIMMY_BASE_GGUF=/app/models \
    SHIMMY_BIND_ADDRESS=0.0.0.0:11434 \
    WGPU_BACKEND=vulkan

VOLUME ["/app/models"]
ENTRYPOINT ["shimmy"]
CMD ["serve"]
