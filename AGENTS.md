# AGENTS.md

This file provides guidance to AI coding agents working in this repository.

## Purpose

This repo is the **single source of truth** for all Protocol Buffers contracts in the TCC LVC platform. It generates language-specific gRPC stubs for three consumer languages: **Java**, **Python**, and **Rust**.

## Common Commands

```bash
# Build and install stubs (Java JAR + Python .py stubs)
mvn clean install -DskipTests

# Build Rust codegen Docker image (one-time)
docker build -t proto-codegen:latest -f codegen.Dockerfile .

# After changing .proto files, rebuild and propagate:
mvn clean install -DskipTests                          # Java + Python
cd ../live-ms-java/live-ms-java && mvn clean compile   # Java consumer
cd ../virtual-ms-java/virtual-areas && mvn clean compile
cd ../constructive-airsim-ms-python && python scripts/gen_proto.py  # Python consumer
cd ../event-hub && cargo build                         # Rust consumer (local)
```

## Build System

- **ascopes protobuf-maven-plugin** handles `.proto` compilation
- **Java** stubs via `protoc-gen-grpc-java` (binary-maven plugin)
- **Python** stubs via `protoc` built-in `--python_out` + `grpc_python_plugin` (path plugin)
- **Rust** stubs via `codegen.Dockerfile` (protoc + protoc-gen-prost + protoc-gen-tonic)
- Output directories:
  - Java: `target/generated-sources/protobuf/java/`
  - Python: `target/generated-sources/protobuf/python/`

## Proto Files

Located in `src/main/proto/`. This is the **only place** `.proto` files exist in the entire project. Consumer repos (`constructive-airsim-ms-python`, `event-hub`) have no local proto copies — they read from here or consume generated stubs.

| File | Services | Consumers |
|---|---|---|
| `event.proto` | `EventHub` (SendEvent, Subscribe) | Java, Python, Rust |
| `virtual_areas.proto` | `AreaService` (CheckEntityInArea, GetActiveAreas) | Java, Python, Rust |
| `bus_event.proto` | `DroneController`, `BusEventHub` | Java, Python, Rust |
| `messaging.proto` | `Messaging` (legacy, kept for tests) | Rust |

After any `.proto` change, all downstream consumers must regenerate stubs. The commands above cover each language.
