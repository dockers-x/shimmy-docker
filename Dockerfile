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
        libssl3 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --home-dir /app --uid 10001 shimmy \
    && mkdir -p /app/models \
    && chown -R shimmy:shimmy /app

COPY --from=builder /app/target/release/shimmy /usr/local/bin/shimmy

USER shimmy
WORKDIR /app
EXPOSE 11434

ENV SHIMMY_BASE_GGUF=/app/models \
    SHIMMY_HOST=0.0.0.0 \
    SHIMMY_PORT=11434

VOLUME ["/app/models"]
ENTRYPOINT ["shimmy"]
CMD ["serve"]
