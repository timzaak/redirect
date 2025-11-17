FROM rust:slim AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Create a minimal stub file for the compiler.
# Cargo will see the manifests and try to compile a minimal binary,
# which forces it to download and compile all dependencies in /target.
RUN mkdir src

# Copy source code
COPY src ./src

# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from builder stage
COPY --from=builder /app/target/release/redirect /app/redirect

# Copy configuration file
# COPY config.release.toml /app/config.toml

EXPOSE 8080

CMD ["./redirect"]