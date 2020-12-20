FROM debian:buster AS builder
ENV WEBDIS_REPO https://github.com/nicolasff/webdis.git

# Install builds deps
RUN apt-get update && apt-get install -y git make gcc libevent-dev

# Move to working directory /build
WORKDIR /build

# Build the application
RUN git clone --depth 1 $WEBDIS_REPO . && make clean && make -j $(nproc) all

# Build a small image
FROM debian:buster

# Install runtime deps
RUN apt-get update && apt-get install -y libevent-dev

# Copy executable into final container
COPY --from=builder /build/webdis /usr/bin

# Command to run
COPY webdis.entrypoint.sh /app.sh
ENTRYPOINT ["/app.sh"]