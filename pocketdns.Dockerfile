FROM golang AS builder

# Set necessary environment variables needed for our image
ENV GOOS=linux GOARCH=amd64 GO111MODULE=on CGO_ENABLED=0

# Move to working directory /build
WORKDIR /build

## Copy and download dependency using go mod
COPY go.mod .
RUN go mod download
COPY go.sum .

# Copy the code into the container
COPY . .

# Build the application
RUN go build -o app .

# Move to /dist directory as the place for resulting binary folder
WORKDIR /dist

# Copy binary from build to app folder
RUN cp /build/app .

# Build a small image
FROM scratch

COPY --from=builder /dist/app /

# Command to run
ENTRYPOINT ["/app"]