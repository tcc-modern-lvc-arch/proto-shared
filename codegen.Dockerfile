# ── Builder stage: compile protoc-gen-prost and protoc-gen-tonic ─────────────
FROM rust:1.85-slim AS builder
RUN apt-get update && apt-get install -y protobuf-compiler && rm -rf /var/lib/apt/lists/*
RUN cargo install protoc-gen-prost protoc-gen-tonic --locked

# ── Runtime stage: protoc + plugins + proto sources ───────────────────────────
FROM debian:12-slim
RUN apt-get update && apt-get install -y protobuf-compiler && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/protoc-gen-prost /usr/local/bin/
COPY --from=builder /usr/local/cargo/bin/protoc-gen-tonic /usr/local/bin/
COPY src/main/proto /proto
WORKDIR /proto
ENTRYPOINT ["sh", "-c", "\
  mkdir -p /out && \
  protoc -I /proto \
    --prost_out=/out \
    --tonic_out=/out \
    $(ls /proto/*.proto)"]
