FROM public.ecr.aws/docker/library/golang:1.24.2-alpine AS build

ENV DOCKERIZE_VERSION=v0.9.3

# Install dependencies
RUN apk update --no-cache \
    && apk add --no-cache wget openssl \
    && wget -O - https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar xzf - -C /usr/local/bin \
    && apk del wget \
    && go install github.com/pressly/goose/v3/cmd/goose@latest

# Set the working directory
WORKDIR /app

# Copy the go.mod and go.sum files
COPY go.mod go.sum ./

# Download the dependencies
RUN go mod download

# Copy the source code
COPY main.go .

# Build the Go application
RUN go build -o main .

# Copy static files
COPY migrations ./migrations

# Use a smaller base image for the final stage
FROM alpine:latest

# Set the working directory
WORKDIR /app

# Copy the binary from the build stage
COPY --from=build /app/main .
COPY static ./static
COPY templates ./templates

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["./main"]
