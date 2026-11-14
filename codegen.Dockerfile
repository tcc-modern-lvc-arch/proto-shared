# ── Builder stage: compile protoc-gen-prost and protoc-gen-tonic ─────────────
FROM rust:1-slim-bookworm AS builder
RUN apt-get update \
 && apt-get install -y --no-install-recommends protobuf-compiler \
 && rm -rf /var/lib/apt/lists/*
RUN cargo install protoc-gen-prost protoc-gen-tonic --locked

# ── Runtime stage: protoc + plugins + proto sources ───────────────────────────
FROM debian:12-slim
RUN apt-get update \
 && apt-get upgrade -y --no-install-recommends \
 && apt-get install -y --no-install-recommends protobuf-compiler \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --system --uid 10001 --no-create-home codegen \
 && mkdir -p /out \
 && chown codegen /out
COPY --from=builder /usr/local/cargo/bin/protoc-gen-prost /usr/local/bin/
COPY --from=builder /usr/local/cargo/bin/protoc-gen-tonic /usr/local/bin/
COPY src/main/proto /proto
WORKDIR /proto
USER codegen
# One-shot code generator, not a long-running service: no HEALTHCHECK needed.
HEALTHCHECK NONE
ENTRYPOINT ["sh", "-c", "\
  mkdir -p /out && \
  protoc -I /proto \
    --prost_out=/out \
    --tonic_out=/out \
    $(ls /proto/*.proto)"]
