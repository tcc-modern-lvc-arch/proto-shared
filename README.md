# proto-shared

Single source of truth for all gRPC/Protobuf contracts in the TCC LVC platform. Generates language-specific stubs for **Java**, **Python**, and **Rust** from a shared set of `.proto` files.

## Tech Stack

- **Java 25** — Build language (Maven)
- **Apache Maven** — Build system
- **Protocol Buffers 4.34** — IDL
- **gRPC 1.79** — RPC framework
- **ascopes protobuf-maven-plugin** — Java + Python codegen
- **Docker** — Rust codegen image (`codegen.Dockerfile`)

## Quick Start

```bash
# Build and install stubs locally (Java JAR + Python stubs)
mvn clean install -DskipTests

# Build Rust codegen image (one-time)
docker build -t proto-codegen:latest -f codegen.Dockerfile .
```

## Proto Sources

All `.proto` files live in `src/main/proto/`. This is the **single source of truth** — no `.proto` files exist anywhere else in the project.

| File | Services | Consumers |
|---|---|---|
| `event.proto` | `EventHub` | Java, Python, Rust |
| `virtual_areas.proto` | `AreaService` | Java, Python, Rust |
| `bus_event.proto` | `DroneController`, `BusEventHub` | Java, Python, Rust |
| `messaging.proto` | `Messaging` (legacy) | Rust |

## Consumer Guides

### Java (`live-ms-java`, `virtual-ms-java`)
```bash
mvn clean install -DskipTests   # publishes JAR to local Maven repo
```
Downstream projects consume via standard Maven dependency. No additional steps.

### Python (`constructive-airsim-ms-python`)
```bash
# Prerequisite: grpc_python_plugin on PATH (pip install grpcio-tools)
mvn clean install -DskipTests   # generates .py stubs in target/
cd ../constructive-airsim-ms-python
python scripts/gen_proto.py     # syncs stubs into src/.../generated/
```

### Rust (`event-hub`)
```bash
# Local dev (fast path):
cargo build                     # build.rs reads ../proto-shared/src/main/proto/

# Docker build:
docker build -t proto-codegen:latest -f codegen.Dockerfile .
cd ../event-hub && docker build -t event-hub .
```

## Documentation

Full schema reference: [Deepwiki](https://deepwiki.com/tcc-modern-lvc-arch/proto-shared)

## License

Apache 2.0
