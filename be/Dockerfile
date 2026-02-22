# ── Stage 1: build ────────────────────────────────────────────────────────────
# Use the official Go image only while building; it won't ship in the final image.
FROM golang:1.23-alpine AS builder

# Install gcc + musl-dev needed by lib/pq (pure-C Postgres driver bits).
RUN apk add --no-cache gcc musl-dev

WORKDIR /app

# Copy dependency manifests first so Docker can cache the download layer
# separately from the source code. Re-downloads only when go.mod/go.sum change.
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source and compile a statically linked binary.
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /app/bin/api ./cmd/api/...


# ── Stage 2: runtime ──────────────────────────────────────────────────────────
# Distroless contains only the app + bare runtime; no shell, no package manager.
# This minimises the attack surface and image size.
FROM gcr.io/distroless/static-debian12

WORKDIR /app

# Copy only the compiled binary from the builder stage.
COPY --from=builder /app/bin/api .

# The API listens on 8080 by default (overridable via PORT env var).
EXPOSE 8080

# Run as a non-root user (distroless ships uid 65532 "nonroot" by default).
USER nonroot:nonroot

ENTRYPOINT ["/app/api"]
