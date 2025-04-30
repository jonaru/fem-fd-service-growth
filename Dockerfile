FROM public.ecr.aws/docker/library/golang:1.24.2-alpine AS build

# Install dependencies
RUN go install github.com/pressly/goose/v3/cmd/goose@latest

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
COPY static ./static
COPY templates ./templates

# Use a smaller base image for the final stage
FROM alpine:latest

# Set the working directory
WORKDIR /app

# Copy the binary from the build stage
COPY --from=build /app/main .

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["./main"]
